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
    let gearJson: String
    
    var jsonModels: [GearJsonModel]? {
        let gj: GearJsonListModel? = gearJson.data(using: .utf8)?.toJsonObject()
        return gj?.gearJson
    }
    
    func getPrimaryFirearm() -> GearJsonModel? {
        return jsonModels?.first { gj in
            gj.isPrimaryFirearm()
        }
    }
}

struct GearListModel: CustomCodeable {
    let charGear: [GearModel]
}

struct GearCreateModel: CustomCodeable {
    let characterId: Int
    let gearJson: String
}

struct GearJsonModel: CustomCodeable, Identifiable {
    
    var id: String {
        name + gearType + primarySubtype + secondarySubtype + desc
    }
    
    let name: String
    let gearType: String
    let primarySubtype: String
    var secondarySubtype: String
    let desc: String
    
    init(name: String, gearType: String, primarySubtype: String, secondarySubtype: String, desc: String) {
        self.name = name
        self.gearType = gearType
        self.primarySubtype = primarySubtype
        self.secondarySubtype = secondarySubtype
        self.desc = desc
    }
    
    func isPrimaryFirearm() -> Bool {
        return secondarySubtype == Constants.GearSecondarySubtype.primaryFirearm
    }
    
    func isEqualTo(other: GearJsonModel) -> Bool {
        return name == other.name &&
        gearType == other.gearType &&
        primarySubtype == other.primarySubtype &&
        secondarySubtype == other.secondarySubtype &&
        desc == other.desc
    }
    
    func clone() -> GearJsonModel {
        return GearJsonModel(name: name, gearType: gearType, primarySubtype: primarySubtype, secondarySubtype: secondarySubtype, desc: desc)
    }
}

struct GearJsonListModel: CustomCodeable {
    let gearJson: [GearJsonModel]
}
