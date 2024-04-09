//
//  GearModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 6/20/23.
//

import Foundation

struct GearModel: CustomCodeable, Identifiable {
    let id: Int
    let characterId: Int
    let type: String
    let name: String
    let description: String
}

struct GearListModel: CustomCodeable {
    let charGear: [GearModel]
}

struct GearCreateModel: CustomCodeable {
    let characterId: Int
    let type: String
    let name: String
    let description: String
}
