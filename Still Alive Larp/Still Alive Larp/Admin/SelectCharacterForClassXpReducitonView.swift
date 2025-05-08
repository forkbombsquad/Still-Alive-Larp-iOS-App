//
//  SelectCharacterForClassXpReducitonView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/29/23.
//

import SwiftUI

struct SelectCharacterForClassXpReducitonView: View {
    @ObservedObject var _dm = DataManager.shared

    let characters: [CharacterModel]

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Select Character For\nXp Reduciton")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .padding(.leading, 32)
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
