//
//  AwardCharacterView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/13/23.
//

import SwiftUI

struct AwardCharacterView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    @State var characters: [CharacterModel]

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Award Character")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        ForEach(characters.alphabetized) { character in
                            NavArrowView(title: character.fullName) { _ in
                                AwardCharacterFormView(character: character)
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
    return AwardCharacterView(_dm: dm, characters: md.characterListFullModel.characters)
}
