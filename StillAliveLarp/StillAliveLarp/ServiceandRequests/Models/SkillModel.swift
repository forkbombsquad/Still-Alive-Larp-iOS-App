//
//  SkillModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/11/23.
//

import Foundation
import SwiftUI

protocol SkillModelProtocol: CustomCodeable, Identifiable {

    var id: Int { get set }
    var xpCost: String { get }
    var prestigeCost: String { get }
    var name: String { get }
    var description: String { get }
    var minInfection: String { get }
    var skillTypeId: Int { get }
    var skillCategoryId: Int { get }
    var prereqs: [OldFullSkillModel] { get set }

}

extension SkillModelProtocol {

    func getModCost(combatMod: Int, professionMod: Int, talentMod: Int, xpReductions: [SpecialClassXpReductionModel]) -> Int {
        var cost = xpCost.intValueDefaultZero
        switch skillTypeId {
            case Constants.SkillTypes.combat:
                cost = xpCost.intValueDefaultZero.addMinOne(combatMod)
            case Constants.SkillTypes.profession:
                cost = xpCost.intValueDefaultZero.addMinOne(professionMod)
            case Constants.SkillTypes.talent:
                cost = xpCost.intValueDefaultZero.addMinOne(talentMod)
            default:
                cost = xpCost.intValueDefaultZero
        }
        for red in xpReductions {
            guard id == red.skillId else { continue }
            cost = cost.addMinOne((-1 * red.xpReduction.intValueDefaultZero))
        }
        return cost
    }

    func getModCost(combatMod: Int, professionMod: Int, talentMod: Int, xpReduction: SpecialClassXpReductionModel) -> Int {
        return getModCost(combatMod: combatMod, professionMod: professionMod, talentMod: talentMod, xpReductions: [xpReduction])
    }

    func getInfModCost(inf50Mod: Int, inf75Mod: Int) -> Int {
        switch minInfection.intValueDefaultZero {
            case 50:
                return inf50Mod
            case 75:
                return inf75Mod
            default:
                return minInfection.intValueDefaultZero
        }
    }

    func getTypeText() -> String {
        switch skillTypeId {
            case Constants.SkillTypes.combat:
                return "Combat"
            case Constants.SkillTypes.profession:
                return "Profession"
            case Constants.SkillTypes.talent:
                return "Talent"
            default:
                return ""
        }
    }

    func getTypeColor() -> Color {
        switch skillTypeId {
            case Constants.SkillTypes.combat:
                return Color.red
            case Constants.SkillTypes.profession:
                return Color.darkGreen
            case Constants.SkillTypes.talent:
                return Color.blue
            default:
                return Color.black
        }
    }

    func getPrereqNames() -> String {
        guard prereqs.count > 0 else { return "" }
        var counter = 0
        var str = ""
        for prereq in prereqs {
            counter += 1
            if counter > 1 {
                str += "\n"
            }
            str += "\(prereq.name)"
        }
        return str
    }

    func includeInFilter(searchText: String, filterType: SkillListView.FilterType) -> Bool {
        let text = searchText.trimmed.lowercased()
        if !text.isEmpty {
            if !name.lowercased().contains(text) && !getTypeText().lowercased().contains(text) && !description.lowercased().contains(text) {
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
                return xpCost.intValueDefaultZero == 0
            case .xp1:
                return xpCost.intValueDefaultZero == 1
            case .xp2:
                return xpCost.intValueDefaultZero == 2
            case .xp3:
                return xpCost.intValueDefaultZero == 3
            case .xp4:
                return xpCost.intValueDefaultZero == 4
            case .pp:
                return prestigeCost.intValueDefaultZero > 0
            case .inf:
                return minInfection.intValueDefaultZero > 0
        }
    }

}

struct SkillModel: CustomCodeable {
    let id: Int
    let xpCost: String
    let prestigeCost: String
    let name: String
    let description: String
    let minInfection: String
    let skillTypeId: Int
    let skillCategoryId: Int
}

struct SkillBarcodeModel: CustomCodeable {
    let id: Int
    let name: String

    init(_ fullSkillModel: OldFullSkillModel) {
        self.id = fullSkillModel.id
        self.name = fullSkillModel.name
    }
}

struct SkillListModel: CustomCodeable {
    let results: [SkillModel]
}

struct FullSkillListModel: CustomCodeable {
    let skills: [OldFullSkillModel]
}

struct CharacterModifiedSkillModel: SkillModelProtocol {
    // TODO remove this
    var id: Int
    let xpCost: String
    let prestigeCost: String
    let name: String
    let description: String
    let minInfection: String
    let skillTypeId: Int
    let skillCategoryId: Int
    var prereqs: [OldFullSkillModel]

    var modXpCost: String
    var modInfCost: String

    var usesPrestige: Bool {
        return self.prestigeCost.intValueDefaultZero > 0
    }
    var canUseFreeSkill: Bool {
        return xpCost.intValueDefaultZero == 1
    }
    var usesInfection: Bool {
        return minInfection.intValueDefaultZero > 0
    }
    var hasModCost: Bool {
        return xpCost.intValueDefaultZero != modXpCost.intValueDefaultZero
    }
    var hasModInfCost: Bool {
        return minInfection.intValueDefaultZero != modInfCost.intValueDefaultZero
    }

    func colorForCost() -> Color {
        if hasModCost {
            if modXpCost.intValueDefaultZero > xpCost.intValueDefaultZero {
                return .red
            } else {
                return .darkGreen
            }
        }
        return .black
    }

    func colorForInf() -> Color {
        if hasModInfCost {
            if modInfCost.intValueDefaultZero < minInfection.intValueDefaultZero {
                return .darkGreen
            }
        }
        return .black
    }

    init(_ skillModel: OldFullSkillModel, modXpCost: Int, modInfCost: Int) {
        self.id = skillModel.id
        self.xpCost = skillModel.xpCost
        self.prestigeCost = skillModel.prestigeCost
        self.name = skillModel.name
        self.description = skillModel.description
        self.minInfection = skillModel.minInfection
        self.skillTypeId = skillModel.skillTypeId
        self.skillCategoryId = skillModel.skillCategoryId
        self.prereqs = skillModel.prereqs
        self.modXpCost = modXpCost.stringValue
        self.modInfCost = modInfCost.stringValue
    }

    var fullSkillModel: OldFullSkillModel {
        return OldFullSkillModel(self)
    }

    func includeModInFilter(searchText: String, filterType: SkillListView.FilterType) -> Bool {
        let text = searchText.trimmed.lowercased()
        if !text.isEmpty {
            if !name.lowercased().contains(text) && !getTypeText().lowercased().contains(text) && !description.lowercased().contains(text) {
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
                return modXpCost.intValueDefaultZero == 0
            case .xp1:
                return modXpCost.intValueDefaultZero == 1
            case .xp2:
                return modXpCost.intValueDefaultZero == 2
            case .xp3:
                return modXpCost.intValueDefaultZero == 3
            case .xp4:
                return modXpCost.intValueDefaultZero == 4
            case .pp:
                return prestigeCost.intValueDefaultZero > 0
            case .inf:
                return modInfCost.intValueDefaultZero > 0
        }
    }

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
    
    func includeInFilter(searchText: String, filterType: SkillListView.FilterType) -> Bool {
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
            text += " (changed from \(baseXpCost())xp with:"
            if getRelevatnSpecCostChange() != 0 {
                text += " \(getRelevatnSpecCostChange()) from \(getTypeText()) Specialization"
            }
            if getRelevatnSpecCostChange() != 0 && hasXpReduction() {
                text += " and"
            }
            if hasXpReduction() {
                text += " \(xpReduction?.xpReduction.intValueDefaultZero ?? 0) from Special Class Xp Reductions"
            }
            text += ")"
        }
        return text
    }
    
    func getInfCostText() -> String {
        var text = ""
        text += "\(modInfectionCost())% Inf Threshold"
        if hasModInfCost() {
            text += " (changed from \(baseInfectionCost())%)"
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
        // TODO
        return FullCharacterModifiedSkillModel(id: id)
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

struct OldFullSkillModel: SkillModelProtocol {
    // TODO get rid of this
    var id: Int
    let xpCost: String
    let prestigeCost: String
    let name: String
    let description: String
    let minInfection: String
    let skillTypeId: Int
    let skillCategoryId: Int
    var prereqs: [OldFullSkillModel]
    var postreqs: [Int] = []

    var barcodeModel: SkillBarcodeModel {
        return SkillBarcodeModel(self)
    }

    init(id: Int, xpCost: String, prestigeCost: String, name: String, description: String, minInfection: String, skillTypeId: Int, skillCategoryId: Int, prereqs: [OldFullSkillModel]) {
        self.id = id
        self.xpCost = xpCost
        self.prestigeCost = prestigeCost
        self.name = name
        self.description = description
        self.minInfection = minInfection
        self.skillTypeId = skillTypeId
        self.skillCategoryId = skillCategoryId
        self.prereqs = prereqs
    }

    init(_ skillModel: SkillModel) {
        self.id = skillModel.id
        self.xpCost = skillModel.xpCost
        self.prestigeCost = skillModel.prestigeCost
        self.name = skillModel.name
        self.description = skillModel.description
        self.minInfection = skillModel.minInfection
        self.skillTypeId = skillModel.skillTypeId
        self.skillCategoryId = skillModel.skillCategoryId
        self.prereqs = []
    }

    init(_ skillModel: CharacterModifiedSkillModel) {
        self.id = skillModel.id
        self.xpCost = skillModel.xpCost
        self.prestigeCost = skillModel.prestigeCost
        self.name = skillModel.name
        self.description = skillModel.description
        self.minInfection = skillModel.minInfection
        self.skillTypeId = skillModel.skillTypeId
        self.skillCategoryId = skillModel.skillCategoryId
        self.prereqs = skillModel.prereqs
    }
    
    func getModCost(
        combatMod: Int,
        professionMod: Int,
        talentMod: Int,
        xpReductions: [SpecialClassXpReductionModel]
    ) -> Int {
        var cost = xpCost.intValueDefaultZero
        switch skillTypeId {
        case Constants.SkillTypes.combat:
            if cost > 0 || combatMod > 0 {
                cost = cost.addMinOne(combatMod)
            }
        case Constants.SkillTypes.profession:
            if cost > 0 || professionMod > 0 {
                cost = cost.addMinOne(professionMod)
            }
        case Constants.SkillTypes.talent:
            if cost > 0 || talentMod > 0 {
                cost = cost.addMinOne(talentMod)
            }
        default:
            break
        }

        for reduction in xpReductions {
            if reduction.skillId == self.id {
                cost = cost.addMinOne(-reduction.xpReduction.intValueDefaultZero)
            }
        }

        return cost
    }

    func getModCost(
        combatMod: Int,
        professionMod: Int,
        talentMod: Int,
        xpReduction: SpecialClassXpReductionModel
    ) -> Int {
        var cost = xpCost.intValueDefaultZero
        switch skillTypeId {
        case Constants.SkillTypes.combat:
            if cost > 0 || combatMod > 0 {
                cost = cost.addMinOne(combatMod)
            }
        case Constants.SkillTypes.profession:
            if cost > 0 || professionMod > 0 {
                cost = cost.addMinOne(professionMod)
            }
        case Constants.SkillTypes.talent:
            if cost > 0 || talentMod > 0 {
                cost = cost.addMinOne(talentMod)
            }
        default:
            break
        }

        if xpReduction.skillId == self.id {
            cost = cost.addMinOne(-xpReduction.xpReduction.intValueDefaultZero)
        }

        return cost
    }

    func getInfModCost(inf50Mod: Int, inf75Mod: Int) -> Int {
        switch minInfection.intValueDefaultZero {
        case 50:
            return inf50Mod
        case 75:
            return inf75Mod
        default:
            return minInfection.intValueDefaultZero
        }
    }

    func getTypeText() -> String {
        switch skillTypeId {
        case Constants.SkillTypes.combat:
            return "Combat"
        case Constants.SkillTypes.profession:
            return "Profession"
        case Constants.SkillTypes.talent:
            return "Talent"
        default:
            return ""
        }
    }

    func getFullCostText(purchaseableSkills: [CharacterModifiedSkillModel]) -> String {
        var text = ""
        let pskill = purchaseableSkills.first(where: { $0.id == self.id })

        if let pskill = pskill {
            if pskill.hasModCost {
                text += "\(pskill.modXpCost)xp (usual cost: \(xpCost)xp)"
            } else {
                text += "\(xpCost)xp"
            }

            if pskill.hasModInfCost, minInfection.intValueDefaultZero > 0 {
                text += " | \(pskill.modInfCost)% Inf Threshold (usual threshold: \(minInfection)%)"
            } else if minInfection.intValueDefaultZero > 0 {
                text += " | \(minInfection)% Inf Threshold"
            }

            if prestigeCost.intValueDefaultZero > 0 {
                text += " | \(prestigeCost)pp"
            }
        } else {
            text += "\(xpCost)xp"
            if minInfection.intValueDefaultZero > 0 {
                text += " | \(minInfection)% Inf Threshold"
            }
            if prestigeCost.intValueDefaultZero > 0 {
                text += " | \(prestigeCost)pp"
            }
        }

        return text
    }

    func getPrereqNames() -> String {
        return prereqs.map { $0.name }.joined(separator: "\n")
    }

    func hasSameCostPrereq() -> Bool {
        return prereqs.contains { $0.xpCost == self.xpCost }
    }

}

