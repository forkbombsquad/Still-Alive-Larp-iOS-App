//
//  CharacterStatusAndGearView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 1/6/23.
//

import SwiftUI

struct CharacterStatusAndGearView: View {
    @ObservedObject private var _dm = DataManager.shared

    let offline: Bool

    init(offline: Bool = false) {
        self.offline = offline
    }

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
                    if let character = DataManager.shared.charForSelectedPlayer {
                        KeyValueView(key: "Name", value: character.fullName)
                        if let playerName = DataManager.shared.selectedPlayer?.fullName {
                            KeyValueView(key: "Player", value: playerName)
                        }
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
        }.padding(16)
        .background(Color.lightGray)
    }
}

struct CharacterBulletsSubView: View {
    @ObservedObject private var _dm = DataManager.shared

    let character: FullCharacterModel

    var body: some View {
        VStack {
            Spacer().frame(height: 48)
            KeyValueView(key: "Bullets", value: character.bullets)
            KeyValueView(key: "Megas", value: character.megas)
            KeyValueView(key: "Rivals", value: character.rivals)
            KeyValueView(key: "Rockets", value: character.rockets, showDivider: false)
        }
    }

}

struct CharacterMaterialsSubView: View {
    @ObservedObject private var _dm = DataManager.shared

    let character: FullCharacterModel

    var body: some View {
        VStack {
            Spacer().frame(height: 48)
            KeyValueView(key: "Bullet Casings", value: character.bulletCasings)
            KeyValueView(key: "Cloth Supplies", value: character.clothSupplies)
            KeyValueView(key: "Wood Supplies", value: character.woodSupplies)
            KeyValueView(key: "Metal Supplies", value: character.metalSupplies)
            KeyValueView(key: "Tech Supplies", value: character.techSupplies)
            KeyValueView(key: "Medical Supplies", value: character.medicalSupplies, showDivider: false)
        }
    }

}

struct CharacterSkillAndArmorSubView: View {
    @ObservedObject private var _dm = DataManager.shared

    let character: FullCharacterModel

    var body: some View {
        VStack {
            let myst = hasMysteriousStrangerTypes()
            let unsh = hasUnshakableResolve()
            if myst || unsh {
                Spacer().frame(height: 48)
                if myst {
                    KeyValueView(key: "Mysterious Stranger Uses (max \(mysteriousStrangerCount()))", value: character.mysteriousStrangerUses)
                }
                if unsh {
                    KeyValueView(key: "Unshakable Resolve Uses (max 1)", value: character.mysteriousStrangerUses)
                }
            }
            Spacer().frame(height: 48)
            KeyValueView(key: "Armor", value: "\(character.armor)")
        }
    }

    func hasMysteriousStrangerTypes() -> Bool {
        for sk in character.skills {
            guard sk.id.equalsAnyOf(Constants.SpecificSkillIds.mysteriousStrangerTypeSkills) else { continue }
            return true
        }
        return false
    }

    func mysteriousStrangerCount() -> Int {
        var count = 0
        for sk in character.skills {
            guard sk.id.equalsAnyOf(Constants.SpecificSkillIds.mysteriousStrangerTypeSkills) else { continue }
            count += 1
        }
        return count
    }

    func hasUnshakableResolve() -> Bool {
        for sk in character.skills {
            guard sk.id == Constants.SpecificSkillIds.unshakableResolve else { continue }
            return true
        }
        return false
    }

}

