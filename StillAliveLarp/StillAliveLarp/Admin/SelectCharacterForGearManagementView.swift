//
//  SelectCharacterForGearManagementView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 6/30/23.
//

import SwiftUI

struct SelectCharacterForGearManagementView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

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
                                // TODO
//                                GearView(character: character, allowEdit: true)
                            }.navigationViewStyle(.stack)
                        }
                    }
                }
            }
        }.padding(16)
        .background(Color.lightGray)
    }
}

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    let md = getMockData()
//    return SelectCharacterForGearManagementView(characters: md.characterListFullModel.characters)
//}
