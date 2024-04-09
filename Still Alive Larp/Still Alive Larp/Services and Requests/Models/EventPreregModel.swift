//
//  EventPreregModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/15/23.
//

import Foundation

enum EventRegType: String {
    case notPrereged = "NONE"
    case free = "FREE"
    case basic = "BASIC"
    case premium = "PREMIUM"

    func getAttendingText() -> String {
        switch self {
        case .notPrereged:
            return "Not Attending"
        case .free:
            return "Free Entry"
        case .basic:
            return "Basic Donation Tier ($15)"
        case .premium:
            return "Premium Donation Tier ($25 or more)"
        }
    }
}

struct EventPreregModel: CustomCodeable, Identifiable {

    let id: Int
    let playerId: Int
    private let characterId: Int?
    let eventId: Int
    let regType: String


    init(id: Int, playerId: Int, characterId: Int?, eventId: Int, regType: String) {
        self.id = id
        self.playerId = playerId
        self.characterId = characterId == nil ? -1 : characterId
        self.eventId = eventId
        self.regType = regType
    }

    var eventRegType: EventRegType {
        return EventRegType(rawValue: regType) ?? .notPrereged
    }

    func getCharId() -> Int? {
        return characterId == -1 ? nil : characterId
    }

}

struct EventPreregListModel: CustomCodeable {
    let eventPreregs: [EventPreregModel]
}

struct EventPreregCreateModel: CustomCodeable {
    let playerId: Int
    private let characterId: Int?
    let eventId: Int
    let regType: String

    init(playerId: Int, characterId: Int?, eventId: Int, regType: EventRegType) {
        self.playerId = playerId
        self.characterId = characterId == nil ? -1 : characterId
        self.eventId = eventId
        self.regType = regType.rawValue
    }

    func getCharId() -> Int? {
        return characterId == -1 ? nil : characterId
    }
}
