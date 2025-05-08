//
//  ChangePasswordListView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/26/23.
//

import SwiftUI

struct ChangePasswordListView: View {
    @ObservedObject private var _dm = DataManager.shared
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
