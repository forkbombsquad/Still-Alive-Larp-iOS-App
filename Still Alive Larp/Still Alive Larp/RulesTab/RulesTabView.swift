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
    let treatingWoundsUrl = URL(string: Constants.urls.treatingWoundsImage)!
    let rulebookUrl = URL(string: Constants.urls.rulebook)!

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
                            NavArrowView(title: "Skill Tree Diagram") { _ in
                                NativeWebImageView(request: URLRequest(url: skillTreeUrl))
                            }
                            NavArrowView(title: "Core Rulebook", loading: DataManager.$shared.loadingRulebook) { _ in
                                ViewRulesView(rulebook: DataManager.shared.rulebook)
                            }
                            NavArrowView(title: "Treating Wounds Flowchart") { _ in
                                NativeWebImageView(request: URLRequest(url: treatingWoundsUrl))
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
            }
        }
    }
}

struct RulesTabView_Previews: PreviewProvider {
    static var previews: some View {
        RulesTabView()
    }
}
