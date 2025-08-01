//
//  AdminService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/13/23.
//

import Foundation

struct AdminService {

    protocol AwardType {
        func getDisplayText(pluralize: Bool) -> String
    }
    
    enum PlayerAwardType: String, CaseIterable, AwardType {
        case xp = "XP"
        case prestigePoints = "PP"
        case freeTier1Skills = "FREE-T1-SKILL"
        
        func getDisplayText(pluralize: Bool) -> String {
            switch self {
            case .xp:
                return "Experience Point\(pluralize ? "s" : "")"
            case .prestigePoints:
                return "Prestige Point\(pluralize ? "s" : "")"
            case .freeTier1Skills:
                return "Free Tier-1 Skill\(pluralize ? "s" : "")"
            }
        }
    }

    enum CharAwardType: String, CaseIterable, AwardType {
        case infection = "INFECTION"
        case materialCasings = "MATERIAL_CASINGS"
        case materialWood = "MATERIAL_WOOD"
        case materialCloth = "MATERIAL_CLOTH"
        case materialMetal = "MATERIAL_METAL"
        case materialTech = "MATERIAL_TECH"
        case materialMed = "MATERIAL_MED"
        case ammoBullet = "AMMO_BULLET"
        case ammoMega = "AMMO_MEGA"
        case ammoRival = "AMMO_RIVAL"
        case ammoRocket = "AMMO_ROCKET"
        
        func getDisplayText(pluralize: Bool) -> String {
            switch self {
            case .infection:
                return "Infection Rating"
            case .materialCasings:
                return "Bullet Casing\(pluralize ? "s" : "")"
            case .materialWood:
                return "Wood"
            case .materialCloth:
                return "Cloth"
            case .materialMetal:
                return "Metal"
            case .materialTech:
                return "Tech Suppl\(pluralize ? "ies" : "y")"
            case .materialMed:
                return "Medical Suppl\(pluralize ? "ies" : "y")"
            case .ammoBullet:
                return "Bullet\(pluralize ? "s" : "")"
            case .ammoMega:
                return "Mega\(pluralize ? "s" : "")"
            case .ammoRival:
                return "Rival\(pluralize ? "s" : "")"
            case .ammoRocket:
                return "Rocket\(pluralize ? "s" : "")"
            }
        }
    }

    static func awardPlayer(_ award: AwardCreateModel, onSuccess: @escaping (_ updatedPlayer: PlayerModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.awardPlayer, bodyJson: award, responseObject: PlayerModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func awardChar(_ award: AwardCreateModel, onSuccess: @escaping (_ updatedCharacter: CharacterModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.awardChar, bodyJson: award, responseObject: CharacterModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func createAnnouncement(_ announcement: CreateAnnouncementModel, onSuccess: @escaping (_ updatedCharacter: AnnouncementModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.announcementCreate, bodyJson: announcement, responseObject: AnnouncementModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func createEvent(_ event: CreateEventModel, onSuccess: @escaping (_ createdEvent: EventModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.createEvent, bodyJson: event, responseObject: EventModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func updateEvent(_ event: EventModel, onSuccess: @escaping (_ updatedEvent: EventModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.eventUpdate, bodyJson: event, responseObject: EventModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func checkInPlayer(_ eventAttendee: EventAttendeeCreateModel, onSuccess: @escaping (_ eventAttendee: EventAttendeeModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.checkInPlayer, bodyJson: eventAttendee, responseObject: EventAttendeeModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func checkInCharacter(_ eventId: Int, characterId: Int, playerId: Int, onSuccess: @escaping (_ updatedCharacter: EventAttendeeModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.checkInCharacter, addToEndOfUrl: "\(eventId)", params: ["player_id": playerId, "character_id": characterId], responseObject: EventAttendeeModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func updateCharacter(_ character: CharacterModel, onSuccess: @escaping (_ characterModel: CharacterModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.updateCharacter, bodyJson: character, responseObject: CharacterModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func giveCharacterCheckInRewards(_ eventId: Int, characterId: Int, playerId: Int, newBulletAmount: Int, onSuccess: @escaping (_ updatedCharacter: CharacterModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.giveCharCheckInRewards, addToEndOfUrl: "\(eventId)", params: ["player_id": playerId, "character_id": characterId, "new_bullet_count": newBulletAmount], responseObject: CharacterModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func updateContactRequest(_ contactRequest: ContactRequestModel, onSuccess: @escaping (_ updatedContactRequest: ContactRequestModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.updateContact, bodyJson: contactRequest, responseObject: ContactRequestModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func getAllContactRequests(onSuccess: @escaping (_ contactRequestList: ContactRequestListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.allContactRequests, responseObject: ContactRequestListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func updatePAdmin(_ newP: String, playerId: Int, onSuccess: @escaping (_ player: PlayerModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.updatePAdmin, addToEndOfUrl: "\(playerId)", headers: ["p": newP], responseObject: PlayerModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func createIntrigue(_ intrigue: IntrigueCreateModel, onSuccess: @escaping (_ intrigue: IntrigueModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.createIntrigue, bodyJson: intrigue, responseObject: IntrigueModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func updateIntrigue(_ intrigue: IntrigueModel, onSuccess: @escaping (_ intrigue: IntrigueModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.updateIntrigue, bodyJson: intrigue, responseObject: IntrigueModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func getAllIntrigues(onSuccess: @escaping (_ intrigue: IntrigueListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.getAllIntrigue, responseObject: IntrigueListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func updatePlayer(_ player: PlayerModel, onSuccess: @escaping (_ playerModel: PlayerModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.updatePlayer, bodyJson: player, responseObject: PlayerModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func updateEventAttendee(_ eventAttendee: EventAttendeeModel, onSuccess: @escaping (_ eventAttendee: EventAttendeeModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.eventAttendeeUpdate, bodyJson: eventAttendee, responseObject: EventAttendeeModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func giveXpReduction(_ characterId: Int, skillId: Int, onSuccess: @escaping (_ xpReduction: SpecialClassXpReductionModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.giveXpReduction, addToEndOfUrl: "\(characterId)", params: ["skill_id": skillId], responseObject: SpecialClassXpReductionModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func createGear(_ gearCreateModel: GearCreateModel, onSuccess: @escaping (_ gearModel: GearModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.createGear, bodyJson: gearCreateModel, responseObject: GearModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func updateGear(gearModel: GearModel, onSuccess: @escaping (_ gearModel: GearModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.updateGear, bodyJson: gearModel, responseObject: GearModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func createFeatureFlag(_ featureFlagCreateModel: FeatureFlagCreateModel, onSuccess: @escaping (_ featureFlagModel: FeatureFlagModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.createFeatureFlag, bodyJson: featureFlagCreateModel, responseObject: FeatureFlagModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func updateFeatureFlag(featureFlagModel: FeatureFlagModel, onSuccess: @escaping (_ featureFlagModel: FeatureFlagModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.updateFeatureFlag, bodyJson: featureFlagModel, responseObject: FeatureFlagModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func deleteFeatureFlag(featureFlagId: Int, onSuccess: @escaping (_ featureFlagModel: FeatureFlagModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.deleteFeatureFlag, addToEndOfUrl: "\(featureFlagId)", responseObject: FeatureFlagModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)

    }
    
    static func createResearchProject(_ researchProjectCreateModel: ResearchProjectCreateModel, onSuccess: @escaping (_ researchProjectModel: ResearchProjectModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.createResearchProject, bodyJson: researchProjectCreateModel, responseObject: ResearchProjectModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }
    
    static func updateResearchProject(_ researchProjectModel: ResearchProjectModel, onSuccess: @escaping (_ researchProjectModel: ResearchProjectModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.updateResearchProject, bodyJson: researchProjectModel, responseObject: ResearchProjectModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
