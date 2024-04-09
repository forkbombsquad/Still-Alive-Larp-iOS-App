//
//  SkillPrereqModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/12/23.
//

import Foundation

struct SkillPrereqModel: CustomCodeable {
    let id: Int
    let baseSkillId: Int
    let prereqSkillId: Int
}

struct SkillPrereqListModel: CustomCodeable {
    let skillPrereqs: [SkillPrereqModel]
}
