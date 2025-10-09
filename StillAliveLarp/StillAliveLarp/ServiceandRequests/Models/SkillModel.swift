//
//  SkillModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/11/23.
//

import Foundation
import SwiftUI

enum SkillFilterType: String, CaseIterable {
    case none = "No Filter"
    case combat = "Combat"
    case profession = "Profession"
    case talent = "Talent"
    case xp0 = "0xp"
    case xp1 = "1xp"
    case xp2 = "2xp"
    case xp3 = "3xp"
    case xp4 = "4xp"
    case pp = "Prestige Points"
    case inf = "Infection Threshold"
}

enum SkillSortType: String, CaseIterable {
    case az = "A-Z"
    case za = "Z-A"
    case xpAsc = "XP Asc"
    case xpDesc = "XP Desc"
    case typeAsc = "Type Asc"
    case typeDesc = "Type Desc"
}

struct SkillModel: CustomCodeable, Identifiable {
    let id: Int
    let xpCost: String
    let prestigeCost: String
    let name: String
    let description: String
    let minInfection: String
    let skillTypeId: Int
    let skillCategoryId: Int
}

struct SkillListModel: CustomCodeable {
    let results: [SkillModel]
}

struct FullCharacterModifiedSkillModel: CustomCodeable, Identifiable {
    private let skill: FullSkillModel
    private let charSkillModel: CharacterSkillModel?
    private let xpReduction: SpecialClassXpReductionModel?
    private let combatXpMod: Int
    private let professionXpMod: Int
    private let talentXpMod: Int
    private let inf50Mod: Int
    private let inf75Mod: Int
    
    init(skill: FullSkillModel, charSkillModel: CharacterSkillModel?, xpReduction: SpecialClassXpReductionModel?, combatXpMod: Int, professionXpMod: Int, talentXpMod: Int, inf50Mod: Int, inf75Mod: Int) {
        self.skill = skill
        self.charSkillModel = charSkillModel
        self.xpReduction = xpReduction
        self.combatXpMod = combatXpMod
        self.professionXpMod = professionXpMod
        self.talentXpMod = talentXpMod
        self.inf50Mod = inf50Mod
        self.inf75Mod = inf75Mod
    }
    
    var skillTypeColor: Color {
        switch skillTypeId {
            case Constants.SkillTypes.combat: return .brightRed
            case Constants.SkillTypes.talent: return .blue
            case Constants.SkillTypes.profession: return .darkGreen
            default: return .black
        }
    }
    
    var colorForXp: Color {
        if hasModCost() {
            if modXpCost() > baseXpCost() {
                return .brightRed
            } else {
                return .darkGreen
            }
        } else {
            return .black
        }
    }
    
    var infColor: Color {
        if hasModInfCost() {
            if modInfectionCost() > baseInfectionCost() {
                return .brightRed
            } else {
                return .darkGreen
            }
        } else {
            return .black
        }
    }
    
    var id: Int {
        return skill.id
    }
    
    var name: String {
        return skill.name
    }
    
    var skillTypeId: Int {
        return skill.skillTypeId
    }
    
    var description: String {
        return skill.description
    }
    
    var category: SkillCategoryModel {
        return skill.category
    }
    
    //
    // Funcs
    //
    
    func isNew(event: FullEventModel) -> Bool {
        return purchaseDate()?.yyyyMMddtoDate().isAfter(event.date.yyyyMMddtoDate()) ?? true
    }
    
    func purchaseDate() -> String? {
        return charSkillModel?.date
    }
    
    func spentXp() -> Int {
        return charSkillModel?.xpSpent ?? 0
    }
    
    func spentFt1s() -> Int {
        return charSkillModel?.fsSpent ?? 0
    }
    
    func spentPp() -> Int {
        return charSkillModel?.ppSpent ?? 0
    }
    
    func prestigeCost() -> Int {
        return skill.prestigeCost
    }
    
    func hasXpReduction() -> Bool {
        return xpReduction != nil
    }
    
    func baseXpCost() -> Int {
        return skill.xpCost
    }
    
    
    func baseInfectionCost() -> Int {
        return skill.minInfection
    }
    
    func getRelevatnSpecCostChange() -> Int {
        switch skill.skillTypeId {
        case Constants.SkillTypes.combat: return combatXpMod
        case Constants.SkillTypes.profession: return professionXpMod
        case Constants.SkillTypes.talent: return talentXpMod
        default: return 0
        }
    }
    
    func modXpCost() -> Int {
        var baseCost = skill.xpCost
        if let xpRed = xpReduction {
            baseCost -= xpRed.xpReduction.intValueDefaultZero
        }
        baseCost += getRelevatnSpecCostChange()
        var m = 1
        if skill.xpCost == 0 {
            m = 0
        }
        return max(m, baseCost)
    }
    
    func modInfectionCost() -> Int {
        var baseCost = skill.minInfection
        if baseCost == 50 {
            baseCost = inf50Mod
        }
        if baseCost == 75 {
            baseCost = inf75Mod
        }
        return max(0, baseCost)
    }
    
    func usesPrestige() -> Bool {
        return skill.prestigeCost > 0
    }
    
    func canUseFreeSkill() -> Bool {
        return skill.xpCost == 1
    }
    
    func usesInfection() -> Bool {
        return baseInfectionCost() > 0
    }
    
    func hasModCost() -> Bool {
        return modXpCost() != baseXpCost()
    }
    
    func hasModInfCost() -> Bool {
        return modInfectionCost() != baseInfectionCost()
    }
    
    func getTypeText() -> String {
        return skill.getTypeText()
    }
    
    func hasPrereqs() -> Bool {
        return skill.prereqs.isNotEmpty
    }
    
    func getPrereqNames() -> String {
        return skill.getPrereqNames()
    }
    
    func includeInFilter(searchText: String, filterType: SkillFilterType) -> Bool {
        let text = searchText.trimmed.lowercased()
        if text.isNotEmpty {
            if !name.lowercased().contains(text) &&
               !getTypeText().lowercased().contains(text) &&
               !description.lowercased().contains(text) &&
               !getPrereqNames().lowercased().contains(text) &&
               !category.name.lowercased().contains(text) {
                return false
            }
        }
        switch filterType {
        case .none:
            return true
        case .combat:
            return skillTypeId == Constants.SkillTypes.combat
        case .profession:
            return skillTypeId == Constants.SkillTypes.profession
        case .talent:
            return skillTypeId == Constants.SkillTypes.talent
        case .xp0:
            return modXpCost() == 0
        case .xp1:
            return modXpCost() == 1
        case .xp2:
            return modXpCost() == 2
        case .xp3:
            return modXpCost() == 3
        case .xp4:
            return modXpCost() >= 4
        case .pp:
            return prestigeCost() > 0
        case .inf:
            return modInfectionCost() > 0
        }
    }
    
    func prereqs() -> [SkillModel] {
        return skill.prereqs
    }
    
    func postreqs() -> [SkillModel] {
        return skill.postreqs
    }
    
    func isPurchased() -> Bool {
        return charSkillModel != nil
    }
    
    func getXpCostText(allowFreeSkillUse: Bool = false) -> String {
        var text = ""
        var usedFreeSkill = false
        if let cs = charSkillModel {
            // Already Purchased
            text += "Already Purchased With:\n"
            if cs.fsSpent > 0 {
                text += "\(cs.fsSpent) Free Tier 1 Skill\(cs.fsSpent.pluralizeString)\n"
                usedFreeSkill = true
            } else {
                text += "\(cs.xpSpent)xp"
            }
        } else {
            // Not Purchased Yet
            if allowFreeSkillUse && canUseFreeSkill() {
                text += "1 Free Tier-1 Skill"
                usedFreeSkill = true
            } else {
                text += "\(modXpCost())xp"
            }
        }
        
        if hasModCost() && !usedFreeSkill {
            text += "\n(changed from \(baseXpCost())xp with:"
            if getRelevatnSpecCostChange() != 0 {
                text += "\n\(getRelevatnSpecCostChange()) from \(getTypeText()) Specialization"
            }
            if getRelevatnSpecCostChange() != 0 && hasXpReduction() {
                text += "\nand"
            }
            if hasXpReduction() {
                text += "\n\(xpReduction?.xpReduction.intValueDefaultZero ?? 0) from Special Class Xp Reductions"
            }
            text += ")"
        }
        return text
    }
    
    func getInfCostText() -> String {
        var text = ""
        text += "\(modInfectionCost())% Inf Threshold"
        if hasModInfCost() {
            text += "\n(changed from \(baseInfectionCost())%)"
        }
        return text
    }
    
    func getPrestigeCostText() -> String {
        var text = ""
        if let cs = charSkillModel {
            text += "\(cs.ppSpent)pp"
        } else {
            text += "\(prestigeCost())pp"
        }
        return text
    }
    
    func getFullCostText() -> String {
        var text = ""
        if let cs = charSkillModel {
            // Already Purchased
            text += getXpCostText()
            if cs.ppSpent > 0 {
                text += "\n\(getPrestigeCostText())"
            }
        } else {
            // Not Purchased Yet
            text += getXpCostText()
            if baseInfectionCost() > 0 {
                text += "\n\(getInfCostText())"
            }
            if usesPrestige() {
                text += "\n\(getPrestigeCostText())"
            }
        }
        return text
    }
    
}

struct FullSkillModel: CustomCodeable, Identifiable {
    let id: Int
    let xpCost: Int
    let prestigeCost: Int
    let name: String
    let description: String
    let minInfection: Int
    let skillTypeId: Int
    let skillCategoryId: Int
    let prereqs: [SkillModel]
    let postreqs: [SkillModel]
    let category: SkillCategoryModel
    
    init(skillModel: SkillModel, prereqs: [SkillModel], postreqs: [SkillModel], category: SkillCategoryModel) {
        self.id = skillModel.id
        self.xpCost = skillModel.xpCost.intValueDefaultZero
        self.prestigeCost = skillModel.prestigeCost.intValueDefaultZero
        self.name = skillModel.name
        self.description = skillModel.description
        self.minInfection = skillModel.minInfection.intValueDefaultZero
        self.skillTypeId = skillModel.skillTypeId
        self.skillCategoryId = skillModel.skillCategoryId
        self.prereqs = prereqs
        self.postreqs = postreqs
        self.category = category
    }
    
    func fullCharacterModifiedSkillModel() -> FullCharacterModifiedSkillModel {
        return FullCharacterModifiedSkillModel(skill: self, charSkillModel: nil, xpReduction: nil, combatXpMod: 0, professionXpMod: 0, talentXpMod: 0, inf50Mod: 50, inf75Mod: 75)
    }
    
    func getTypeText() -> String {
        switch skillTypeId {
            case Constants.SkillTypes.combat: return "Combat"
            case Constants.SkillTypes.profession: return "Profession"
            case Constants.SkillTypes.talent: return "Talent"
            default: return ""
        }
    }
    
    func getPrereqNames() -> String {
        var str = ""
        for (index, prereq) in prereqs.enumerated() {
            if index > 0 {
                str += "\n"
            }
            str += prereq.name
        }
        return str
    }
    
}
