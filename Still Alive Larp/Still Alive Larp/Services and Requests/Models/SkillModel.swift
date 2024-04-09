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
    var prereqs: [FullSkillModel] { get set }

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

    init(_ fullSkillModel: FullSkillModel) {
        self.id = fullSkillModel.id
        self.name = fullSkillModel.name
    }
}

struct SkillListModel: CustomCodeable {
    let results: [SkillModel]
}

struct CharacterModifiedSkillModel: SkillModelProtocol {

    var id: Int
    let xpCost: String
    let prestigeCost: String
    let name: String
    let description: String
    let minInfection: String
    let skillTypeId: Int
    let skillCategoryId: Int
    var prereqs: [FullSkillModel]

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

    init(_ skillModel: FullSkillModel, modXpCost: Int, modInfCost: Int) {
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

    var fullSkillModel: FullSkillModel {
        return FullSkillModel(self)
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

struct FullSkillModel: SkillModelProtocol {
    var id: Int
    let xpCost: String
    let prestigeCost: String
    let name: String
    let description: String
    let minInfection: String
    let skillTypeId: Int
    let skillCategoryId: Int
    var prereqs: [FullSkillModel]

    var barcodeModel: SkillBarcodeModel {
        return SkillBarcodeModel(self)
    }

    init(id: Int, xpCost: String, prestigeCost: String, name: String, description: String, minInfection: String, skillTypeId: Int, skillCategoryId: Int, prereqs: [FullSkillModel]) {
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

}
