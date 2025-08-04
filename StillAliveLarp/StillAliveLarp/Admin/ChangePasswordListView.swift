//
//  ChangePasswordListView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/26/23.
//

import SwiftUI

struct ChangePasswordListView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    @State var players: [PlayerModel]

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Change Player Password")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        ForEach(players.alphabetized) { player in
                            NavArrowView(title: player.fullName) { _ in
                                ChangePlayerPasswordView(player: player)
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
    return ChangePasswordListView(_dm: dm, players: md.playerList.players)
}
