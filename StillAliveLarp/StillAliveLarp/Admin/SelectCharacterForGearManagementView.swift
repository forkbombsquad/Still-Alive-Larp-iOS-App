//
//  SelectCharacterForGearManagementView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 6/30/23.
//

import SwiftUI

struct SelectCharacterForGearManagementView: View {
    @ObservedObject var _dm = OldDataManager.shared

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
                            .padding(.horizontal, 32)
                        ForEach(characters.alphabetized) { character in
                            NavArrowView(title: character.fullName) { _ in
                                GearView(character: character, allowEdit: true)
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
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return SelectCharacterForGearManagementView(_dm: dm, characters: md.characterListFullModel.characters)
}
