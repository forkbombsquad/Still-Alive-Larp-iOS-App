//
//  ViewPlayerView.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 8/7/25.
//

import SwiftUI

struct ViewPlayerView: View {
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    let player: FullPlayerModel
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text(DM.getTitlePotentiallyOffline(player.fullName))
                            .font(.stillAliveTitleFont)
                            .frame(alignment: .center)
                        Image(uiImage: player.profileImage?.uiImage ?? UIImage(imageLiteralResourceName: "blank-profile"))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding(.bottom, 8)
                        NavArrowView(title: "View Player Stats") { _ in
                            // TODO
                        }
                        NavArrowView(title: "View Player Awards") { _ in
                            // TODO
                        }
                        CharacterPanel(fromAccount: false, player: player, character: player.getActiveCharacter())
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
    return ViewPlayerView(player: md.fullPlayers().first!)
}
