//
//  SkillManager.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/11/23.
//

import Foundation

class SkillManager {

    static let shared = SkillManager()

    private init() {}

    private var skills: [FullSkillModel]?
    private var fetching = false

    private var completionBlocks = [((skills: [FullSkillModel]) -> Void)?]()

    func getSkillsOffline() -> [FullSkillModel] {
        LocalDataHandler.shared.getSkills() ?? []
    }


    func getSkills(overrideLocal: Bool = false, _ completion: ((_ skills: [FullSkillModel]) -> Void)? = nil) {
        if !overrideLocal, let skills = skills {
            completion?(skills)
        } else {
            completionBlocks.append(completion)
            guard !fetching else { return }
            fetching = true
            SkillService.getAllSkills { skillListModel in
                self.skills = []
                for s in skillListModel.results {
                    self.skills?.append(FullSkillModel(s))
                }
                SkillPrereqService.getAllSkillPrereqs { skillPrereqListModel in
                    let prereqs = skillPrereqListModel.skillPrereqs
                    for (index, skill) in (self.skills ?? []).enumerated() {
                        for prereq in prereqs.filter({ $0.baseSkillId == skill.id }) {
                            if let pskill = self.skills?.first(where: { $0.id == prereq.prereqSkillId }) {
                                self.skills?[index].prereqs.append(pskill)
                            }
                        }
                    }
                    for (index, skill) in (self.skills ?? []).enumerated() {
                        for prereq in prereqs.filter({ $0.prereqSkillId == skill.id }) {
                            if let prereqSkill = self.skills?.first(where: { $0.id == prereq.baseSkillId }) {
                                self.skills?[index].postreqs.append(prereqSkill.id)
                            }
                        }
                    }
                    LocalDataHandler.shared.storeSkills(self.skills ?? [])
                    self.fetching = false
                    for cb in self.completionBlocks {
                        cb?(self.skills ?? [])
                    }
                    self.completionBlocks = []
                } failureCase: { _ in
                    self.fetching = false
                    for cb in self.completionBlocks {
                        cb?(self.skills ?? [])
                    }
                    self.completionBlocks = []
                }

            } failureCase: { _ in
                self.fetching = false
                for cb in self.completionBlocks {
                    cb?(self.skills ?? [])
                }
                self.completionBlocks = []
            }
        }
    }

}
