//
//  CommunityTabView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/25/23.
//

import SwiftUI

struct CommunityTabView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    PullToRefresh(coordinateSpaceName: "pullToRefresh_CommunityTab", spinnerOffsetY: -100, pullDownDistance: 150) {
                        DM.load()
                    }
                    globalCreateTitleView("Community", DM: DM)
                    LoadingLayoutView {
                        VStack {
                            NavArrowView(title: "All Players") { _ in
                                PlayersListView(title: "All Players", destination: .viewPlayer, players: DM.players)
                            }
                            NavArrowView(title: "Camp Status") { _ in
                                if let cs = DM.campStatus {
                                    ViewCampStatusView(campStatus: cs)
                                }
                            }
                            NavArrowView(title: "All NPCs") { _ in
                                NPCListView(npcs: DM.getAllCharacters(.npc), title: "All NPCs", destination: .view)
                            }
                            NavArrowView(title: "Research Projects") { _ in
                                ViewOrManageResearchProjectsView(researchProjects: DM.researchProjects, allowEdit: false)
                            }
                        }
                    }
                    
                }.coordinateSpace(name: "pullToRefresh_CommunityTab")
            }.padding(16)
            .background(Color.lightGray)
        }.navigationViewStyle(.stack)
    }
}

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    return CommunityTabView()
//}
