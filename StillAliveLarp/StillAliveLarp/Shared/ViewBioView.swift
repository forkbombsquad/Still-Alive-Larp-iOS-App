//
//  ViewBioView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/25/23.
//

import SwiftUI

struct ViewBioView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @Binding var character: FullCharacterModel?

    var body: some View {
        VStack(alignment: .center) {
            ScrollView {
                VStack {
                    if let character = character {
                        globalCreateTitleView("\(character.fullName)'s\nBio", DM: DM)
                        if !DM.offlineMode && (DM.playerIsCurrentPlayer(character.playerId)) {
                            NavArrowViewRed(title: "Edit Bio") {
                                EditBioView(character: $character, bio: character.bio)
                            }
                        }
                        Text(character.bio)
                            .padding(.vertical, 16)
                            .frame(alignment: .leading)
                            .multilineTextAlignment(.leading)
                        
                    }
                }
            }
            HStack {
                Spacer()
            }
        }.padding(16)
        .background(Color.lightGray)
    }
}
