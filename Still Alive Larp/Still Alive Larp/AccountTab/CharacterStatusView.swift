//
//  CharacterStatusView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 1/6/23.
//

import SwiftUI

struct CharacterStatusView: View {
    @ObservedObject var _dm = DataManager.shared
    
    static func Offline(character: FullCharacterModel) -> CharacterStatusView {
        return CharacterStatusView(offline: true, character: character)
    }
    
    init() {
        self.offline = false
        self._character = globalState(DataManager.shared.charForSelectedPlayer)
    }
    
    private init (offline: Bool, character: FullCharacterModel?) {
        self.offline = offline
        self._character = globalState(character)
    }
    
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
        }
        .padding(16)
        .background(Color.lightGray)
    }
}

struct CharacterBulletsSubView: View {
    @ObservedObject var _dm = DataManager.shared

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
    @ObservedObject var _dm = DataManager.shared

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
    @ObservedObject var _dm = DataManager.shared

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

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    var csv = CharacterStatusView()
    csv._dm = dm
    return csv
}

