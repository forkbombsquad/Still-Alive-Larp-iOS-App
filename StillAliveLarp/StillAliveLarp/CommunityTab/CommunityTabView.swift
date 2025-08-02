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
                        AllNpcsListView(npcs: allNpcs, allowEdit: false)
                    }
                    NavArrowView(title: "Research Projects", loading: $loadingAllResearchProjects) { _ in
                        AllResearchProjectsListView(researchProjects: allResearchProjects, allowEdit: false)
                    }
                }
            }.padding(16)
            .background(Color.lightGray)
            .onAppear {
                self.loadingAllPlayers = true
                self.loadingAllNpcs = true
                self.loadingAllResearchProjects = true
                OldDataManager.shared.load([.allPlayers, .npcs, .researchProjects]) {
                    runOnMainThread {
                        self.allPlayers = OldDataManager.shared.allPlayers ?? []
                        self.allNpcs = OldDataManager.shared.npcs
                        self.allResearchProjects = OldDataManager.shared.researchProjects
                        self.loadingAllPlayers = false
                        self.loadingAllNpcs = false
                        self.loadingAllResearchProjects = false
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
    dm.loadingAllPlayers = false
    return CommunityTabView(_dm: dm)
}
