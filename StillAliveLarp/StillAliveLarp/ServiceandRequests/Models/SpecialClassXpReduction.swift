//
//  SpecialClassXpReduction.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/29/23.
//

import Foundation

struct XpReductionModel: CustomCodeable, Identifiable {
    let id: Int
    let characterId: Int
    let skillId: Int
    let xpReduction: String
}

struct XpReductionListModel: CustomCodeable {
    let specialClassXpReductions: [XpReductionModel]

    var skillIds: [Int] {
        var ids = [Int]()
        for xpRd in specialClassXpReductions {
            ids.append(xpRd.skillId)
        }
        return ids
    }
}
