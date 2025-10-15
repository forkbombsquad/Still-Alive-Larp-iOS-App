//
//  PlayerModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/4/22.
//

import Foundation

struct FullPlayerModel: CustomCodeable, Identifiable {
    let id: Int
    let username: String
    let fullName: String
    let startDate: String
    let experience: Int
    let freeTier1Skills: Int
    let prestigePoints: Int
    let isCheckedIn: Bool
    let isCheckedInAsNpc: Bool
    let lastCheckIn: String
    let numEventsAttended: Int
    let numNpcEventsAttended: Int
    let isAdmin: Bool
    let characters: [FullCharacterModel]
    let awards: [AwardModel]
    let eventAttendees: [EventAttendeeModel]
    let preregs: [EventPreregModel]
    let profileImage: ProfileImageModel?
    
    init(player: PlayerModel, characters: [FullCharacterModel], awards: [AwardModel], eventAttendees: [EventAttendeeModel], preregs: [EventPreregModel], profileImage: ProfileImageModel?) {
        self.id = player.id
        self.username = player.username
        self.fullName = player.fullName
        self.startDate = player.startDate
        self.experience = player.experience.intValueDefaultZero
        self.freeTier1Skills = player.freeTier1Skills.intValueDefaultZero
        self.prestigePoints = player.prestigePoints.intValueDefaultZero
        self.isCheckedIn = player.isCheckedIn.boolValueDefaultFalse
        self.isCheckedInAsNpc = player.isCheckedInAsNpc.boolValueDefaultFalse
        self.lastCheckIn = player.lastCheckIn
        self.numEventsAttended = player.numEventsAttended.intValueDefaultZero
        self.numNpcEventsAttended = player.numNpcEventsAttended.intValueDefaultZero
        self.isAdmin = player.isAdmin.boolValueDefaultFalse
        self.characters = characters
        self.awards = awards
        self.eventAttendees = eventAttendees
        self.preregs = preregs
        self.profileImage = profileImage
    }
    
    func getActiveCharacter() -> FullCharacterModel? {
        return characters.first(where: { $0.characterType() == .standard && $0.isAlive })
    }
    
    func getInactiveCharacters() -> [FullCharacterModel] {
        return characters.filter({ $0.characterType() == .standard && !$0.isAlive })
    }
    
    func getPlannedCharacters() -> [FullCharacterModel] {
        return characters.filter({ $0.characterType() == .planner })
    }
    
    func getAwardsSorted() -> [AwardModel] {
        return awards.sorted { (a, b) -> Bool in
            return a.date > b.date
        }
    }
    
    func getCheckInBarcodeModel(useChar: Bool, event: FullEventModel) -> CheckInOutBarcodeModel {
        let activeChar = getActiveCharacter()
        if useChar && activeChar != nil {
            return CheckInOutBarcodeModel(playerId: id, characterId: activeChar?.id, eventId: event.id)
        } else {
            return CheckInOutBarcodeModel(playerId: id, eventId: event.id)
        }
    }
    
    func getCheckOutBarcodeModel(eventAttendee: EventAttendeeModel) -> CheckInOutBarcodeModel {
        if characters.first(where: { $0.id == eventAttendee.characterId }) != nil {
            return CheckInOutBarcodeModel(playerId: eventAttendee.playerId, characterId: eventAttendee.characterId, eventId: eventAttendee.eventId)
        } else {
            return CheckInOutBarcodeModel(playerId: eventAttendee.playerId, eventId: eventAttendee.eventId)
        }
    }
    
    func baseModel() -> PlayerModel {
        return PlayerModel(self)
    }
    
    func baseModelWithModifications(xpChange: Int, ft1sChange: Int, ppChange: Int) -> PlayerModel {
        return PlayerModel(id: id,
                           username: username,
                           fullName: fullName,
                           startDate: startDate,
                           experience: (experience + xpChange).stringValue,
                           freeTier1Skills: (freeTier1Skills + ft1sChange).stringValue,
                           prestigePoints: (prestigePoints + ppChange).stringValue,
                           isCheckedIn: isCheckedIn.stringValue,
                           isCheckedInAsNpc: isCheckedInAsNpc.stringValue,
                           lastCheckIn: lastCheckIn,
                           numEventsAttended: numEventsAttended.stringValue,
                           numNpcEventsAttended: numNpcEventsAttended.stringValue,
                           isAdmin: isAdmin.stringValue)
    }
    
    func getUniqueCharacterNameRec(name: String, incrementalCount: Int? = nil) -> String {
        let fName = "\(name)\((incrementalCount == nil) ? "" : "\(incrementalCount!)")"
        if characters.first(where: { $0.fullName == fName }) == nil {
            return fName
        } else {
            return getUniqueCharacterNameRec(name: name, incrementalCount: incrementalCount == nil ? 1 : incrementalCount! + 1)
        }
    }
    
}

struct PlayerModel: CustomCodeable, Identifiable {
    let id: Int
    let username: String
    let fullName: String
    let startDate: String
    let experience: String
    let freeTier1Skills: String
    let prestigePoints: String
    let isCheckedIn: String
    let isCheckedInAsNpc: String
    let lastCheckIn: String
    let numEventsAttended: String
    let numNpcEventsAttended: String
    let isAdmin: String
    
    init(id: Int, username: String, fullName: String, startDate: String, experience: String, freeTier1Skills: String, prestigePoints: String, isCheckedIn: String, isCheckedInAsNpc: String, lastCheckIn: String, numEventsAttended: String, numNpcEventsAttended: String, isAdmin: String) {
        self.id = id
        self.username = username
        self.fullName = fullName
        self.startDate = startDate
        self.experience = experience
        self.freeTier1Skills = freeTier1Skills
        self.prestigePoints = prestigePoints
        self.isCheckedIn = isCheckedIn
        self.isCheckedInAsNpc = isCheckedInAsNpc
        self.lastCheckIn = lastCheckIn
        self.numEventsAttended = numEventsAttended
        self.numNpcEventsAttended = numNpcEventsAttended
        self.isAdmin = isAdmin
    }
    
    init(_ player: FullPlayerModel) {
        self.id = player.id
        self.username = player.username
        self.fullName = player.fullName
        self.startDate = player.startDate
        self.experience = player.experience.stringValue
        self.freeTier1Skills = player.freeTier1Skills.stringValue
        self.prestigePoints = player.prestigePoints.stringValue
        self.isCheckedIn = player.isCheckedIn.stringValue
        self.isCheckedInAsNpc = player.isCheckedInAsNpc.stringValue
        self.lastCheckIn = player.lastCheckIn
        self.numEventsAttended = player.numEventsAttended.stringValue
        self.numNpcEventsAttended = player.numNpcEventsAttended.stringValue
        self.isAdmin = player.isAdmin.stringValue
    }
}

struct PlayerCreateModel: CustomCodeable {
    let username: String
    let fullName: String
    let startDate: String
    let experience: String
    let freeTier1Skills: String
    let prestigePoints: String
    let isCheckedIn: String
    let isCheckedInAsNpc: String
    let lastCheckIn: String
    let numEventsAttended: String
    let numNpcEventsAttended: String
    let isAdmin: String
    let password: String
}

struct PlayerListModel: CustomCodeable {
    var players: [PlayerModel]
}
