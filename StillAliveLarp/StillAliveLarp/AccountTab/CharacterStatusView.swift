//
//  CharacterStatusView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 1/6/23.
//

import SwiftUI

// TODO redo view

struct CharacterStatusView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    let offline: Bool
    @State var character: FullCharacterModel? = nil

    var body: some View {
        VStack(alignment: .center) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center) {
                    Text("Character Status\(offline ? " (Offline)" : "")")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(alignment: .center)
                        .padding([.bottom], 16)
                    Divider()
                    if let character = character {
                        KeyValueView(key: "Name", value: character.fullName)
//                        if let playerName = OldDM.selectedPlayer?.fullName {
//                            KeyValueView(key: "Player", value: playerName)
//                        }
                        KeyValueView(key: "Start Date", value: character.startDate.yyyyMMddToMonthDayYear())
                        KeyValueView(key: "Infection Rating", value: "\(character.infection)%", showDivider: false)
                        CharacterBulletsSubView(character: character)
                        CharacterMaterialsSubView(character: character)
                        CharacterSkillAndArmorSubView(character: character)
                    }
                }
            }
            HStack {
                Spacer()
            }
        }
        .padding(16)
        .background(Color.lightGray)
    }
}

struct CharacterBulletsSubView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let character: FullCharacterModel

    var body: some View {
        VStack {
            Spacer().frame(height: 48)
            KeyValueView(key: "Bullets", value: character.bullets.stringValue)
            KeyValueView(key: "Megas", value: character.megas.stringValue)
            KeyValueView(key: "Rivals", value: character.rivals.stringValue)
            KeyValueView(key: "Rockets", value: character.rockets.stringValue, showDivider: false)
        }
    }

}

struct CharacterMaterialsSubView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let character: FullCharacterModel

    var body: some View {
        VStack {
            Spacer().frame(height: 48)
            KeyValueView(key: "Bullet Casings", value: character.bulletCasings.stringValue)
            KeyValueView(key: "Cloth Supplies", value: character.clothSupplies.stringValue)
            KeyValueView(key: "Wood Supplies", value: character.woodSupplies.stringValue)
            KeyValueView(key: "Metal Supplies", value: character.metalSupplies.stringValue)
            KeyValueView(key: "Tech Supplies", value: character.techSupplies.stringValue)
            KeyValueView(key: "Medical Supplies", value: character.medicalSupplies.stringValue, showDivider: false)
        }
    }

}

struct CharacterSkillAndArmorSubView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let character: FullCharacterModel

    var body: some View {
        VStack {
            let myst = character.mysteriousStrangerCount() > 0
            let unsh = character.hasUnshakableResolve()
            if myst || unsh {
                Spacer().frame(height: 48)
                if myst {
                    KeyValueView(key: "Mysterious Stranger Uses (max \(character.mysteriousStrangerCount())", value: character.mysteriousStrangerUses.stringValue)
                }
                if unsh {
                    KeyValueView(key: "Unshakable Resolve Uses (max 1)", value: character.unshakableResolveUses.stringValue)
                }
            }
            Spacer().frame(height: 48)
            KeyValueView(key: "Armor", value: "\(character.armor)")
        }
    }

}

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    let md = getMockData()
//    return CharacterStatusView()
//}

