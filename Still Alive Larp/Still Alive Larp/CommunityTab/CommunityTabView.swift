//
//  CommunityTabView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/25/23.
//

import SwiftUI

struct CommunityTabView: View {
    @ObservedObject var _dm = DataManager.shared

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    Text("Community")
                        .font(.system(size: 32, weight: .bold))
                        .frame(alignment: .center)
                    NavArrowView(title: "All Players", loading: DataManager.$shared.loadingAllPlayers) { _ in
                        ForEach(DataManager.shared.allPlayers?.alphabetized ?? []) { player in
                            // TODO this, use the code below to help
//                            NavArrowView(title: "\(player.fullName)\((player.isAdmin.uppercased() == "TRUE") ? " (Staff)" : "")") { _ in
//                                ViewPlayerStuffView(player: player)
//                            }.navigationViewStyle(.stack)
                        }
                    }
                    if FeatureFlag.campStatus.isActive() {
                        NavArrowView(title: "Camp Status") { _ in
                            // TODO
                        }
                    }
                    NavArrowView(title: "All NPCs") { _ in
                        // TODO
                    }
                    NavArrowView(title: "Research Projects") { _ in
                        // TODO
                    }
                }
            }.padding(16)
            .background(Color.lightGray)
            .onAppear {
                DataManager.shared.load([.allPlayers, .npcs, .researchProjects])
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
