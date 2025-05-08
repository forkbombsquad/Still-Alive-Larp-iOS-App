//
//  AwardPlayerView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/13/23.
//

import SwiftUI

struct AwardPlayerView: View {
    @ObservedObject var _dm = DataManager.shared

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

struct AwardPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        let dm = DataManager.shared
        dm.debugMode = true
        dm.loadMockData()
        return AwardPlayerView(_dm: dm, players: DataManager.shared.allPlayers!)
    }
}
