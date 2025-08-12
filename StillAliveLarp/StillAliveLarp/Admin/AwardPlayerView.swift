//
//  AwardPlayerView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/13/23.
//

import SwiftUI

// TODO update view if needed

struct AwardPlayerView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @State var players: [PlayerModel]

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Award Player")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        ForEach(players.alphabetized) { player in
                            NavArrowView(title: player.fullName) { _ in
                                AwardPlayerFormView(player: player)
                            }.navigationViewStyle(.stack)
                        }
                    }
                }
            }
        }.padding(16)
        .background(Color.lightGray)
    }
}

#Preview {
    DataManager.shared.setDebugMode(true)
    let md = getMockData()
    return AwardPlayerView(players: md.playerList.players)
}
