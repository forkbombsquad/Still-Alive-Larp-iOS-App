//
//  SkillCell.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 10/9/25.
//

import SwiftUI

struct SkillCell: View {
    
    static func initAsBase(skill: FullCharacterModifiedSkillModel) -> SkillCell {
        return SkillCell(player: nil, character: nil, skill: skill, loading: .constant(false), loadingText: .constant(""), purchaseText: "", showInfoLayout: true, showPurchaseLayout: false, showButton: false, onTap: { _ in })
    }
    
    static func initForXpReduction(player: FullPlayerModel, character: FullCharacterModel, skill: FullCharacterModifiedSkillModel, loading: Binding<Bool>, loadingText: Binding<String>, onXpReductionTap: @escaping (_ skill: FullCharacterModifiedSkillModel) -> Void) -> SkillCell {
        return SkillCell(player: player, character: character, skill: skill, loading: loading, loadingText: loadingText, purchaseText: "Give Xp Reduction", showInfoLayout: true, showPurchaseLayout: false, showButton: true, onTap: onXpReductionTap)
    }
    
    static func initForPurchase(skill:FullCharacterModifiedSkillModel, player: FullPlayerModel, character: FullCharacterModel,  loading: Binding<Bool>, loadingText: Binding<String>, onPressPurchase: @escaping (_ skill: FullCharacterModifiedSkillModel) -> Void) -> SkillCell {
        return SkillCell(player: player, character: character, skill: skill, loading: loading, loadingText: loadingText, purchaseText: character.characterType() == .planner ? "Plan Skill" : "Purchase Skill", showInfoLayout: false, showPurchaseLayout: true, showButton: true, onTap: onPressPurchase)
    }
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let player: FullPlayerModel?
    let character: FullCharacterModel?
    let skill: FullCharacterModifiedSkillModel
    @Binding var loading: Bool
    @Binding var loadingText: String

    let onTap: (_ skill: FullCharacterModifiedSkillModel) -> Void
    
    let purchaseText: String
    let showInfoLayout: Bool
    let showPurchaseLayout: Bool
    let showButton: Bool
    
    init(player: FullPlayerModel?, character: FullCharacterModel?, skill: FullCharacterModifiedSkillModel, loading: Binding<Bool>, loadingText: Binding<String>, purchaseText: String, showInfoLayout: Bool, showPurchaseLayout: Bool, showButton: Bool, onTap: @escaping (_: FullCharacterModifiedSkillModel) -> Void) {
        self.player = player
        self.character = character
        self.skill = skill
        self._loading = loading
        self._loadingText = loadingText
        self.onTap = onTap
        self.purchaseText = purchaseText
        self.showInfoLayout = showInfoLayout
        self.showPurchaseLayout = showPurchaseLayout
        self.showButton = showButton
    }

    var body: some View {
        CardView {
            VStack {
                HStack {
                    Text(skill.name)
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Text(skill.getTypeText())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(skill.skillTypeColor)
                }
                if showInfoLayout {
                    HStack {
                        Spacer()
                        Text(skill.getXpCostText())
                            .frame(alignment: .center)
                            .multilineTextAlignment(.center)
                        if skill.usesPrestige() {
                            Spacer()
                            Text(skill.getPrestigeCostText())
                                .frame(alignment: .center)
                                .multilineTextAlignment(.center)
                        }
                        if skill.usesInfection() {
                            Spacer()
                            Text(skill.getInfCostText())
                                .frame(alignment: .center)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }
                }
                if showPurchaseLayout, let player = player, let character {
                    HStack {
                        let text = skill.getXpCostText(allowFreeSkillUse: player.freeTier1Skills > 0 && character.characterType() == .standard)
                        Spacer()
                        Text(text)
                            .frame(alignment: .center)
                            .multilineTextAlignment(.center)
                            .foregroundColor(text.containsIgnoreCase("free") ? .darkGreen : (skill.hasModCost() ? skill.colorForXp : .black))
                        if skill.usesPrestige() {
                            Spacer()
                            Text(skill.getPrestigeCostText())
                                .frame(alignment: .center)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.blue)
                        }
                        if skill.usesInfection() {
                            Spacer()
                            Text("\(character.characterType() == .standard ? "Your Infection Rating meets the required:" : "Will require:")\n\(skill.getInfCostText())")
                                .frame(alignment: .center)
                                .multilineTextAlignment(.center)
                                .foregroundColor(skill.hasModInfCost() ? skill.infColor : .black)
                        }
                        Spacer()
                    }
                }

                if skill.prereqs().count > 0 {
                    Divider().background(Color.darkGray).padding([.leading, .trailing], 8)
                    Text("Prerequisites").font(.system(size: 14, weight: .bold))
                    Text(skill.getPrereqNames()).padding(.top, 8).multilineTextAlignment(.center)
                    Divider().background(Color.darkGray).padding([.leading, .trailing], 8)
                }
                Text(skill.description).padding(.top, 8)
                if showButton {
                    LoadingButtonView($loading, loadingText: $loadingText, width: 180, buttonText: purchaseText) {
                        onTap(skill)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.lightGray)
    }

}


/*
 
 freeSkill = 6
 longSkill = 72
 prestigeSkill = 23
 infSkill = 14
 specSkill = 19
 manyPrereqs = 47
 
 md.fullSkills().first(where: { $0.id == infSkill })!.fullCharacterModifiedSkillModel()
 
 md.fullCharacters().first!.allNonPurchasedSkills().first!
 
 md.fullCharacters().first!.allPurchasedSkills().first!
 */

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    let md = getMockData()
//    let char = md.fullCharacters().first!
//    let player = md.fullPlayers().first!
//    return SkillCell.initForPurchase(skill: char.allNonPurchasedSkills()[8], player: player, character: char, loading: .constant(false), loadingText: .constant(""), onPressPurchase: { _ in })
//}
