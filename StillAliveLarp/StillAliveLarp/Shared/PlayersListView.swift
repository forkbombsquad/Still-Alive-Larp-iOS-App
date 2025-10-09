//
//  PlayersListView.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 8/7/25.
//

import SwiftUI

struct PlayersListView: View {
    
    enum PlayersListViewDestination {
        case viewPlayer, awardPlayer, changePass
    }
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    let title: String
    let destination: PlayersListViewDestination
    let players: [FullPlayerModel]
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        globalCreateTitleView(title, DM: DM)
                        LazyVStack(spacing: 8) {
                            ForEach(players.alphabetized) { player in
                                NavArrowView(title: "\(player.fullName)\(player.isAdmin ? " (Staff)" : "")") { _ in
                                    switch destination {
                                    case .viewPlayer:
                                        ViewPlayerView(player: player)
                                    case .awardPlayer:
                                        AwardPlayerView(player: player)
                                    case .changePass:
                                        ChangePlayerPasswordView(player: player)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
    }
}

#Preview {
    DataManager.shared.setDebugMode(true)
    let md = getMockData()
    return PlayersListView(title: "All Players", destination: .viewPlayer, players: md.fullPlayers())
}
