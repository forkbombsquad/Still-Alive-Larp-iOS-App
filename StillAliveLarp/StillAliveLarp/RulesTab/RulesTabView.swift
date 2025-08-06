//
//  RulesTabView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/11/23.
//

import SwiftUI

struct RulesTabView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { gr in
                    ScrollView {
                        PullToRefresh(coordinateSpaceName: "pullToRefresh_RulesTab", spinnerOffsetY: -100, pullDownDistance: 150) {
                            DM.load(loadType: .forceDownload)
                        }
                        VStack {
                            Text(DM.getTitlePotentiallyOffline("Rules and Reference"))
                                .font(.stillAliveTitleFont)
                                .frame(alignment: .center)
                            LoadingLayoutView {
                                VStack {
                                    NavArrowView(title: "Skill List") { _ in
                                        // TODO
        //                                SkillListView(skills: allSkills)
                                    }
                                    NavArrowView(title: "Skill Tree Diagram") { _ in
                                        // TODO
        //                                NativeSkillTree(skillGrid: SkillGrid(skills: self.allSkills, skillCategories: self.skillCategories, personal: false, allowPurchase: false))
                                    }
                                    NavArrowView(title: "Core Rulebook") { _ in
                                        ViewRulesView(rulebook: DM.rulebook)
                                    }
                                    NavArrowView(title: "Treating Wounds Flowchart") { _ in
                                        if let image = DM.treatingWounds {
                                            DownloadedImageView(image: image)
                                        }
                                    }
                                }
                            }
                        }
                    }.coordinateSpace(name: "pullToRefresh_RulesTab")
                }
            }
            .padding(16)
            .background(Color.lightGray)
        }.navigationViewStyle(.stack)
    }
}

#Preview {
    DataManager.shared.setDebugMode(true)
    return RulesTabView()
}
