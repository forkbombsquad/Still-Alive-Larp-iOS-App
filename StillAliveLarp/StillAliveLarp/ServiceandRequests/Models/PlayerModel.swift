//
//  PlayerModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/4/22.
//

import Foundation

struct FullPlayerModel: CustomCodeable, Identifiable {
    let id: Int
    // TODO
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
