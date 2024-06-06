//
//  RulesTabView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/11/23.
//

import SwiftUI

struct RulesTabView: View {
    @ObservedObject private var _dm = DataManager.shared

    @State var loadingSkills: Bool = true
    @State var allSkills = [FullSkillModel]()
    let skillTreeUrl = URL(string: Constants.urls.skillTreeImage)!
    let skillTreeUrlDark = URL(string: Constants.urls.skillTreeImageDark)!
    let treatingWoundsUrl = URL(string: Constants.urls.treatingWoundsImage)!
    let rulebookUrl = URL(string: Constants.urls.rulebook)!

    @State var loadingSkillTreeDiagram: Bool = true
    @State var loadingSkillTreeDiagramDark: Bool = true
    @State var loadingTreatingWoundsDiagram: Bool = true

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
                            NavArrowView(title: "Skill Tree Diagram", loading: $loadingSkillTreeDiagram) { _ in
                                if let image = LocalDataHandler.shared.getImage(.skillTree) {
                                    DownloadedImageView(image: image)
                                }
                            }
                            NavArrowView(title: "Skill Tree Diagram (Dark)", loading: $loadingSkillTreeDiagramDark) { _ in
                                if let image = LocalDataHandler.shared.getImage(.skillTreeDark) {
                                    DownloadedImageView(image: image)
                                }
                            }
                            NavArrowView(title: "Core Rulebook", loading: DataManager.$shared.loadingRulebook) { _ in
                                ViewRulesView(rulebook: DataManager.shared.rulebook)
                            }
                            NavArrowView(title: "Treating Wounds Flowchart", loading: $loadingTreatingWoundsDiagram) { _ in
                                if let image = LocalDataHandler.shared.getImage(.treatingWounds) {
                                    DownloadedImageView(image: image)
                                }
                            }
                        }
                    }
                }
            }.padding(16)
            .background(Color.lightGray)
            .onAppear {
                self.loadingSkills = true
                SkillManager.shared.getSkills { skills in
                    self.allSkills = skills
                    self.loadingSkills = false
                }
                DataManager.shared.load([.rulebook])

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
        }
    }
}

struct RulesTabView_Previews: PreviewProvider {
    static var previews: some View {
        RulesTabView()
    }
}
