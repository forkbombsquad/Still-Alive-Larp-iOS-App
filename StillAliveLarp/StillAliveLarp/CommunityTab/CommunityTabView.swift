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
                        DM.load(loadType: .forceDownload)
                    }
                    Text(DM.getTitlePotentiallyOffline("Community"))
                        .font(.stillAliveTitleFont)
                    LoadingLayoutView {
                        VStack {
                            NavArrowView(title: "All Players") { _ in
                                // TODO
//                                AllPlayersListView(allPlayers: allPlayers)
                            }
                            NavArrowView(title: "Camp Status") { _ in
                                // TODO
                                // Camp Status View
                            }
                            NavArrowView(title: "All NPCs") { _ in
                                // TODO
//                                AllNpcsListView(npcs: allNpcs, allowEdit: false)
                            }
                            NavArrowView(title: "Research Projects") { _ in
                                // TODO
//                                AllResearchProjectsListView(researchProjects: allResearchProjects, allowEdit: false)
                            }
                        }
                    }
                    
                }.coordinateSpace(name: "pullToRefresh_CommunityTab")
            }.padding(16)
            .background(Color.lightGray)
        }.navigationViewStyle(.stack)
    }
}

#Preview {
    DataManager.shared.setDebugMode(true)
    return CommunityTabView()
}
