//
//  CharacterSkill.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/14/23.
//

import Foundation

struct CharacterSkillModel: CustomCodeable {
    let id: Int
    let characterId: Int
    let skillId: Int
    let xpSpent: Int
    let fsSpent: Int
    let ppSpent: Int
    let date: String
}

struct CharacterSkillListModel: CustomCodeable {
    let charSkills: [CharacterSkillModel]
}

struct CharacterSkillCreateModel: CustomCodeable {
    let characterId: Int
    let skillId: Int
    let xpSpent: Int
    let fsSpent: Int
    let ppSpent: Int
}
