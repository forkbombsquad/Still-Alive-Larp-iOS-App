//
//  RulesTabView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/11/23.
//

import SwiftUI

struct RulesTabView: View {
    @ObservedObject var _dm = OldDataManager.shared

    @State var loadingSkills: Bool = true
    @State var allSkills = [OldFullSkillModel]()
    @State var skillCategories = [SkillCategoryModel]()
    
    let skillTreeUrl = URL(string: Constants.urls.skillTreeImage)!
    let skillTreeUrlDark = URL(string: Constants.urls.skillTreeImageDark)!
    let treatingWoundsUrl = URL(string: Constants.urls.treatingWoundsImage)!
    let rulebookUrl = URL(string: Constants.urls.rulebook)!

    @State var loadingSkillTreeDiagram: Bool = true
    @State var loadingSkillTreeDiagramDark: Bool = true
    @State var loadingTreatingWoundsDiagram: Bool = true
    @State var loadingSkillCategories: Bool = true

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    GeometryReader { gr in
                        VStack {
                            Text("Rules and Reference")
                                .font(.system(size: 32, weight: .bold))
                                .frame(alignment: .center)
                            NavArrowView(title: "Skill List", loading: $loadingSkills) { _ in
                                SkillListView(skills: allSkills)
                            }
                            NavArrowView(title: "Skill Tree Diagram", loading: $loadingSkills) { _ in
                                NativeSkillTree(skillGrid: SkillGrid(skills: self.allSkills, skillCategories: self.skillCategories, personal: false, allowPurchase: false))
                            }
                            NavArrowView(title: "Core Rulebook", loading: OldDataManager.$shared.loadingRulebook) { _ in
                                ViewRulesView(rulebook: OldDataManager.shared.rulebook)
                            }
                            NavArrowView(title: "Treating Wounds Flowchart", loading: $loadingTreatingWoundsDiagram) { _ in
                                if let image = OldLocalDataHandler.shared.getImage(.treatingWounds) {
                                    DownloadedImageView(image: image)
                                }
                            }
                            if (FeatureFlag.oldSkillTreeImage.isActive()) {
                                NavArrowView(title: "Skill Tree Diagram Image (Legacy)", loading: $loadingSkillTreeDiagramDark) { _ in
                                    if let image = OldLocalDataHandler.shared.getImage(.skillTreeDark) {
                                        DownloadedImageView(image: image)
                                    }
                                }
                                NavArrowView(title: "Dark Skill Tree Diagram Image (Legacy)", loading: $loadingSkillTreeDiagramDark) { _ in
                                    if let image = OldLocalDataHandler.shared.getImage(.skillTreeDark) {
                                        DownloadedImageView(image: image)
                                    }
                                }
                            }
                        }
                    }
                }
            }.padding(16)
            .background(Color.lightGray)
            .onAppear {
                self.loadingSkills = true
                OldDataManager.shared.load([.rulebook])

                DispatchQueue.global(qos: .userInitiated).async {
                    let imageDownloader = ImageDownloader()
                    imageDownloader.download(key: .skillTree) { success in
                        runOnMainThread {
                            self.loadingSkillTreeDiagram = false
                        }
                    }
                    imageDownloader.download(key: .skillTreeDark) { success in
                        runOnMainThread {
                            self.loadingSkillTreeDiagramDark = false
                        }
                    }
                    imageDownloader.download(key: .treatingWounds) { success in
                        runOnMainThread {
                            self.loadingTreatingWoundsDiagram = false
                        }
                    }
                }
                self.loadingSkillCategories = true
                OldDataManager.shared.load([.skillCategories]) {
                    runOnMainThread {
                        self.skillCategories = OldDataManager.shared.skillCategories
                        self.loadingSkillCategories = false
                        SkillManager.shared.getSkills(overrideLocal: true) { skills in
                            self.allSkills = skills
                            self.loadingSkills = false
                        }
                    }
                }
            }
        }.navigationViewStyle(.stack)
    }
}

#Preview {
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    dm.loadingRulebook = false
    return RulesTabView(_dm: dm)
}
