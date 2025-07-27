//
//  SpecialClassXpReduction.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/29/23.
//

import Foundation

// TODO rename this to XpReductionModel
struct SpecialClassXpReductionModel: CustomCodeable, Identifiable {
    let id: Int
    let characterId: Int
    let skillId: Int
    let xpReduction: String
}

struct SpecialClassXpReductionListModel: CustomCodeable {
    let specialClassXpReductions: [SpecialClassXpReductionModel]

    var skillIds: [Int] {
        var ids = [Int]()
        for xpRd in specialClassXpReductions {
            ids.append(xpRd.skillId)
        }
        return ids
    }
}

struct SpecialClassXpReductionCreateModel: CustomCodeable {
    let characterId: Int
    let skillId: Int
    let xpReduction: String
}
