//
//  SelectCharacterForClassXpReducitonView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/29/23.
//

import SwiftUI

struct SelectCharacterForClassXpReducitonView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let characters: [CharacterModel]

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Select Character For\nXp Reduciton")
                            .font(.system(size: 32, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        ForEach(characters.alphabetized) { character in
                            NavArrowView(title: character.fullName) { _ in
                                SelectSkillForClassXpReducitonView(character: character)
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
    return SelectCharacterForClassXpReducitonView(characters: md.characterListFullModel.characters)
}
