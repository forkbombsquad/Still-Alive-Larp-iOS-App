//
//  AwardPlayerView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/13/23.
//

import SwiftUI

struct AwardPlayerView: View {
    @ObservedObject private var _dm = DataManager.shared

    @State var players: [PlayerModel]

    var body: some View {
        VStack {
            ScrollView {
                GeometryReader { gr in
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
        AwardPlayerView(players: MockData1.playerList.players)
    }
}
