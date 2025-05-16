//
//  SkillCategoryModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/16/25.
//

struct SkillCategoryModel: CustomCodeable, Identifiable {
    let id: Int
    let name: String
}

struct SKillCategoryListModel: CustomCodeable {
    let results: [SkillCategoryModel]
}
