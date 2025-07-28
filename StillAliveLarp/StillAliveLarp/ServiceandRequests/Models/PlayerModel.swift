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
    let profileImage: ProfileImageModel
    
    init(player: PlayerModel, characters: [FullCharacterModel], awards: [AwardModel], eventAttendees: [EventAttendeeModel], preregs: [EventPreregModel], profileImage: ProfileImageModel) {
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
    
    // TODO still need to do
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

    var barcodeModel: PlayerBarcodeModel {
        return PlayerBarcodeModel(self)
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

struct PlayerBarcodeModel: CustomCodeable, Identifiable {
    let id: Int
    let fullName: String
    let isCheckedIn: String
    let lastCheckIn: String
    let numEventsAttended: String
    let numNpcEventsAttended: String

    init(_ playerModel: PlayerModel) {
        self.id = playerModel.id
        self.fullName = playerModel.fullName
        self.isCheckedIn = playerModel.isCheckedIn
        self.lastCheckIn = playerModel.lastCheckIn
        self.numEventsAttended = playerModel.numEventsAttended
        self.numNpcEventsAttended = playerModel.numNpcEventsAttended
    }
}
