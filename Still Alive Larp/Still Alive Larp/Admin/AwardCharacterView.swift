//
//  AwardCharacterView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/13/23.
//

import SwiftUI

struct AwardCharacterView: View {
    @ObservedObject var _dm = DataManager.shared
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

struct AwardCharacterView_Previews: PreviewProvider {
    static var previews: some View {
        let dm = DataManager.shared
        dm.debugMode = true
        dm.loadMockData()
        return AwardCharacterView(_dm: dm, characters: DataManager.shared.allCharacters!)
    }
}
