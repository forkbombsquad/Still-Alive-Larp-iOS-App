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
    
    func getGearOrganized() -> [String : [GearJsonModel]] {
        let gear = jsonModels
        if let g = gear {
            var firearms = [GearJsonModel]()
            var melee = [GearJsonModel]()
            var clothing = [GearJsonModel]()
            var accessory = [GearJsonModel]()
            var bag = [GearJsonModel]()
            var other = [GearJsonModel]()
            for jg in g {
                switch jg.gearType {
                case Constants.GearTypes.firearm: firearms.append(jg)
                case Constants.GearTypes.meleeWeapon: melee.append(jg)
                case Constants.GearTypes.clothing: clothing.append(jg)
                case Constants.GearTypes.accessory: accessory.append(jg)
                case Constants.GearTypes.bag: bag.append(jg)
                case Constants.GearTypes.other: other.append(jg)
                default: continue
                }
            }
            
            // Sorting firearms
            firearms = firearms.sorted {
                let lhsPrimary = $0.isPrimaryFirearm() ? 0 : 1
                let rhsPrimary = $1.isPrimaryFirearm() ? 0 : 1
                if lhsPrimary != rhsPrimary {
                    return lhsPrimary < rhsPrimary
                }

                let lhsOrder = subtypeOrder($0.primarySubtype)
                let rhsOrder = subtypeOrder($1.primarySubtype)
                return lhsOrder < rhsOrder
            }

            // Sorting melee
            melee = melee.sorted {
                subtypeOrder($0.primarySubtype) < subtypeOrder($1.primarySubtype)
            }

            // Sorting accessory
            accessory = accessory.sorted {
                subtypeOrder($0.primarySubtype) < subtypeOrder($1.primarySubtype)
            }

            // Sorting bag
            bag = bag.sorted {
                subtypeOrder($0.primarySubtype) < subtypeOrder($1.primarySubtype)
            }

            // Create gear map
            return [
                Constants.GearTypes.firearm: firearms,
                Constants.GearTypes.meleeWeapon: melee,
                Constants.GearTypes.clothing: clothing,
                Constants.GearTypes.accessory: accessory,
                Constants.GearTypes.bag: bag,
                Constants.GearTypes.other: other
            ]
            
        } else {
            return [:]
        }
        
    }
    
    private func subtypeOrder(_ subtype: String) -> Int {
        switch subtype {
        case Constants.GearPrimarySubtype.lightFirearm: return 0
        case Constants.GearPrimarySubtype.mediumFirearm: return 1
        case Constants.GearPrimarySubtype.heavyFirearm: return 2
        case Constants.GearPrimarySubtype.advancedFirearm: return 3
        case Constants.GearPrimarySubtype.militaryGradeFirearm: return 4

        case Constants.GearPrimarySubtype.superLightMeleeWeapon: return 0
        case Constants.GearPrimarySubtype.lightMeleeWeapon: return 1
        case Constants.GearPrimarySubtype.mediumMeleeWeapon: return 2
        case Constants.GearPrimarySubtype.heavyMeleeWeapon: return 3

        case Constants.GearPrimarySubtype.blacklightFlashlight: return 0
        case Constants.GearPrimarySubtype.flashlight: return 1
        case Constants.GearPrimarySubtype.other: return 2

        case Constants.GearPrimarySubtype.smallBag: return 0
        case Constants.GearPrimarySubtype.mediumBag: return 1
        case Constants.GearPrimarySubtype.largeBag: return 2
        case Constants.GearPrimarySubtype.extraLargeBag: return 3

        default: return Int.max
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
