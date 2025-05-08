//
//  SelectCharacterForGearManagementView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 6/30/23.
//

import SwiftUI

struct SelectCharacterForGearManagementView: View {
    @ObservedObject private var _dm = DataManager.shared

    let characters: [CharacterModel]

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Select Character For\nGear Management")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .padding(.leading, 32)
                        ForEach(characters.alphabetized) { character in
                            NavArrowView(title: character.fullName) { _ in
                                SelectGearToManageView(character: character)
                            }.navigationViewStyle(.stack)
                        }
                    }
                }
            }
        }.padding(16)
        .background(Color.lightGray)
    }
}
