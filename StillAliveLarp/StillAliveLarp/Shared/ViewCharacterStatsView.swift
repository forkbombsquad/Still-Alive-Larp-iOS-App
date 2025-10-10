//
//  ViewCharacterStatsView.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 10/10/25.
//

import SwiftUI

struct ViewCharacterStatsView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let character: FullCharacterModel

    var body: some View {
        VStack(alignment: .center) {
            ScrollView {
                VStack(alignment: .center) {
                    globalCreateTitleView("Character Stats", DM: DM)
                        .padding([.bottom], 16)
                    Divider()
                    KeyValueView(key: "Name", value: character.fullName)
                    KeyValueView(key: "Player", value: DM.getPlayerForCharacter(character).fullName)
                    KeyValueView(key: "Start Date", value: character.startDate.yyyyMMddToMonthDayYear())
                    KeyValueView(key: "Events Attended", value: character.eventAttendees.count)
                    KeyValueView(key: "Infection Rating", value: "\(character.infection)%\(getInfThresholdText())")
                        .padding(.bottom, 32)
                    KeyValueView(key: "Bullets", value: character.bullets)
                    KeyValueView(key: "Megas", value: character.megas)
                    KeyValueView(key: "Rivals", value: character.rivals)
                    KeyValueView(key: "Rockets", value: character.rockets)
                        .padding(.bottom, 32)
                    KeyValueView(key: "Bullet Casings", value: character.bullets)
                    KeyValueView(key: "Cloth Supplies", value: character.bullets)
                    KeyValueView(key: "Wood Supplies", value: character.megas)
                    KeyValueView(key: "Metal Supplies", value: character.rivals)
                    KeyValueView(key: "Tech Supplies", value: character.rockets)
                    KeyValueView(key: "Medical Supplies", value: character.rockets)
                        .padding(.bottom, 32)
                    KeyValueView(key: "Skills", value: getSkillsText())
                    KeyValueView(key: "Spent Xp", value: character.getSpentXp())
                    KeyValueView(key: "Spent Free Tier-1 Skills", value: character.getSpentFt1s())
                    KeyValueView(key: "Spent Prestige Points", value: character.getSpentPps())
                        .padding(.bottom, 32)
                    if showMysteriousStranger() {
                        KeyValueView(key: "Mysterious Stranger Uses Remaining", value: getMysteriousStrangerText())
                    }
                    if showUnshakableResolve() {
                        KeyValueView(key: "Unshakable Resolve Uses Remaining", value: getUnshakableResolveText())
                    }
                    KeyValueView(key: "Armor", value: character.armor)
                        .padding(.bottom, 32)
                    
                    if showCharId() {
                        KeyValueView(key: "CharacterId", value: character.id)
                            .padding(.bottom, 32)
                    }
                    
                }
            }
            HStack {
                Spacer()
            }
        }.padding(16)
        .background(Color.lightGray)
    }
    
    private func getInfThresholdText() -> String {
        var threshold = ""
        let infThresholds = character.infection / 25
        if infThresholds > 0 {
            threshold = "(Threshold \(infThresholds)"
        }
        return threshold
    }
    
    private func getSkillsText() -> String {
        let skills = character.allPurchasedSkills()
        let cskills = skills.filter({ $0.skillTypeId == Constants.SkillTypes.combat })
        let tskills = skills.filter({ $0.skillTypeId == Constants.SkillTypes.talent })
        let pskills = skills.filter({ $0.skillTypeId == Constants.SkillTypes.profession })
        return """
        \(skills.count) Total
        (\(cskills.count) Combat)
        (\(tskills.count) Talent)
        (\(pskills.count) Profession)
        """
    }
    
    private func showMysteriousStranger() -> Bool {
        return character.mysteriousStrangerCount() > 0
    }
    
    private func showUnshakableResolve() -> Bool {
        return character.hasUnshakableResolve()
    }
    
    private func showCharId() -> Bool {
        let currentPlayer = DM.getCurrentPlayer()
        if character.playerId == currentPlayer?.id {
            return true
        }
        return currentPlayer?.isAdmin == true
    }
    
    private func getMysteriousStrangerText() -> String {
        return "\(character.mysteriousStrangerCount() - character.mysteriousStrangerUses) / \(character.mysteriousStrangerCount())"
    }
    
    private func getUnshakableResolveText() -> String {
        return "\((character.hasUnshakableResolve() ? 1 : 0) - character.unshakableResolveUses) / \(character.hasUnshakableResolve() ? 1 : 0)"
    }
}
