//
//  CommunityTabView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/25/23.
//

import SwiftUI

struct CommunityTabView: View {
    @ObservedObject var _dm = DataManager.shared
    
    @State var allPlayers: [PlayerModel] = []
    @State var loadingAllPlayers: Bool = true
    @State var allNpcs: [CharacterModel] = []
    @State var loadingAllNpcs: Bool = true
    @State var allResearchProjects: [ResearchProjectModel] = []
    @State var loadingAllResearchProjects: Bool = true

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    Text("Community")
                        .font(.system(size: 32, weight: .bold))
                        .frame(alignment: .center)
                    NavArrowView(title: "All Players", loading: $loadingAllPlayers) { _ in
                        AllPlayersListView(allPlayers: allPlayers)
                    }
                    if FeatureFlag.campStatus.isActive() {
                        NavArrowView(title: "Camp Status") { _ in
                            // TODO sometime in the future
                        }
                    }
                    NavArrowView(title: "All NPCs", loading: $loadingAllNpcs) { _ in
                        AllNpcsListView(npcs: allNpcs)
                    }
                    NavArrowView(title: "Research Projects", loading: $loadingAllResearchProjects) { _ in
                        // TODO
                    }
                }
            }.padding(16)
            .background(Color.lightGray)
            .onAppear {
                globalTestPrint("ON APPEAR: COMMUNITY TAB VIEW")
                self.loadingAllPlayers = true
                self.loadingAllNpcs = true
                self.loadingAllResearchProjects = true
                DataManager.shared.load([.allPlayers, .npcs, .researchProjects]) {
                    runOnMainThread {
                        self.allPlayers = DataManager.shared.allPlayers ?? []
                        self.allNpcs = DataManager.shared.npcs
                        self.allResearchProjects = DataManager.shared.researchProjects
                        self.loadingAllPlayers = false
                        self.loadingAllNpcs = false
                        self.loadingAllResearchProjects = false
                    }
                }
            }.onDisappear {
                globalTestPrint("ON DISAPPEAR: COMMUNITY TAB VIEW")
            }
        }
    }
}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    dm.loadingAllPlayers = false
    return CommunityTabView(_dm: dm)
}
