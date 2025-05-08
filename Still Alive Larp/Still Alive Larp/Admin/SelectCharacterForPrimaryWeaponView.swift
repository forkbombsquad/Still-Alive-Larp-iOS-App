//
//  SelectCharacterForPrimaryWeaponView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 6/29/23.
//

import SwiftUI

struct SelectCharacterForPrimaryWeaponView: View {
    @ObservedObject private var _dm = DataManager.shared

    let characters: [CharacterModel]

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Select Character For\nPrimary Weapon Registration")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .padding(.leading, 32)
                        ForEach(characters.alphabetized) { character in
                            NavArrowView(title: character.fullName) { _ in
                                RegisterPrimaryWeaponView(character: character)
                            }.navigationViewStyle(.stack)
                        }
                    }
                }
            }
        }.padding(16)
        .background(Color.lightGray)
    }
}
