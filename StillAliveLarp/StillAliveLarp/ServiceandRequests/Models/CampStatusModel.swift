//
//  CampStatusModel.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 8/1/25.
//

import Foundation

struct CampStatusModel: CustomCodeable {
    let id: Int
    let campFortificationJson: String
    
    init(id: Int, campFortificationJson: String) {
        self.id = id
        self.campFortificationJson = campFortificationJson
    }
    
    init(id: Int, campFortifications: [CampFortification]) {
        self.id = id
        self.campFortificationJson = CampFortifications(campFortifications: campFortifications).toJsonString() ?? ""
    }
    
    var campFortifications: [CampFortification] {
        let cf: CampFortifications? = campFortificationJson.data(using: .utf8)?.toJsonObject()
        return cf?.campFortifications ?? []
    }
}

struct CampFortification: CustomCodeable, Identifiable {
    var id: Int { ring }
    
    var ring: Int
    var fortifications: [Fortification]
}

struct Fortification: CustomCodeable, Identifiable {
    var id = UUID()
    
    var type: String
    var health: Int
    
    var fortificationType: FortificationType {
        return FortificationType(rawValue: type) ?? .light
    }
    
    init(type: String, health: Int) {
        self.type = type
        self.health = health
    }
    
    init(type: FortificationType, health: Int) {
        self.type = type.rawValue
        self.health = health
    }
    
    enum FortificationType: String {
        case light = "LIGHT"
        case medium = "MEDIUM"
        case heavy = "HEAVY"
        case advanced = "ADVANCED"
        case militaryGrade = "MILITARY GRADE"
        
        func getMaxHealth() -> Int {
            switch self {
            case .light:
                return 5
            case .medium:
                return 10
            case .heavy:
                return 15
            case .advanced:
                return 20
            case .militaryGrade:
                return 30
            }
        }
    }
}

struct CampFortifications: CustomCodeable {
    let campFortifications: [CampFortification]
}
