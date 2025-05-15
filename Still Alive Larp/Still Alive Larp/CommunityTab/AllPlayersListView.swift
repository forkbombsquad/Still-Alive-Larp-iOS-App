//
//  AllPlayersListView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/14/25.
//

import SwiftUI

struct AllPlayersListView: View {
    
    @ObservedObject var _dm = DataManager.shared
    
    @State var allPlayers: [PlayerModel]
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("All Players")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        LazyVStack(spacing: 8) {
                            ForEach(allPlayers.sorted(by: { first, second in
                                first.fullName < second.fullName
                            })) { player in
                                NavArrowView(title: player.fullName) { attachedObject in
                                    ViewPlayerStuffView(player: player)
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
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return AllPlayersListView(_dm: dm, allPlayers: md.playerList.players)
}
