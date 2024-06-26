//
//  AwardCharacterView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/13/23.
//

import SwiftUI

struct AwardCharacterView: View {
    @ObservedObject private var _dm = DataManager.shared
    @State var characters: [CharacterModel]

    var body: some View {
        VStack {
            ScrollView {
                GeometryReader { gr in
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

struct AwardCharacterView_Previews: PreviewProvider {
    static var previews: some View {
        AwardCharacterView(characters: MockData1.characterListFullModel.characters)
    }
}
