//
//  SkillManager.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/11/23.
//

import Foundation

class SkillManager {
    
    // TODO remove this boi completely

    static let shared = SkillManager()

    private init() {}

    private var skills: [OldFullSkillModel]?
    private var fetching = false

    private var completionBlocks = [((skills: [OldFullSkillModel]) -> Void)?]()

    func getSkillsOffline() -> [OldFullSkillModel] {
        OldLocalDataHandler.shared.getSkills() ?? []
    }


    func getSkills(overrideLocal: Bool = false, _ completion: ((_ skills: [OldFullSkillModel]) -> Void)? = nil) {
        if !overrideLocal, let skills = skills {
            completion?(skills)
        } else {
            completionBlocks.append(completion)
            guard !fetching else { return }
            fetching = true
            SkillService.getAllSkills { skillListModel in
                var fullSkills: [OldFullSkillModel] = []
                for s in skillListModel.results {
                    fullSkills.append(OldFullSkillModel(s))
                }
                SkillPrereqService.getAllSkillPrereqs { skillPrereqListModel in
                    let prereqs = skillPrereqListModel.skillPrereqs
                    for prereq in prereqs {
                        if let baseSkillIndex = fullSkills.firstIndex(where: { $0.id == prereq.baseSkillId }), let prereqSkill = fullSkills.first(where: { $0.id == prereq.prereqSkillId }), let prereqIndex = fullSkills.firstIndex(where: { $0.id == prereq.prereqSkillId }) {
                            fullSkills[prereqIndex].postreqs.append(prereq.baseSkillId)
                            fullSkills[baseSkillIndex].prereqs.append(prereqSkill)
                        }
                        
                    }
                    
                    self.skills = fullSkills
                    OldLocalDataHandler.shared.storeSkills(self.skills ?? [])
                    self.fetching = false
                    for cb in self.completionBlocks {
                        cb?(self.skills ?? [])
                    }
                    self.completionBlocks = []
                } failureCase: { _ in
                    self.skills = fullSkills
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
