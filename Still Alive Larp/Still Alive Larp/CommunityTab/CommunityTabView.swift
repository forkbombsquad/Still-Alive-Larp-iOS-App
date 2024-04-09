//
//  CommunityTabView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/25/23.
//

import SwiftUI

struct CommunityTabView: View {
    @ObservedObject private var _dm = DataManager.shared

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    Text("Community")
                        .font(.system(size: 32, weight: .bold))
                        .frame(alignment: .center)
                    if DataManager.shared.loadingAllPlayers {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        ForEach(DataManager.shared.allPlayers?.alphabetized ?? []) { player in
                            NavArrowView(title: player.fullName) { _ in
                                ViewPlayerStuffView(player: player)
                            }.navigationViewStyle(.stack)
                        }
                    }
                }
            }.padding(16)
            .background(Color.lightGray)
            .onAppear {
                DataManager.shared.load([.allPlayers])
            }
        }
    }
}
