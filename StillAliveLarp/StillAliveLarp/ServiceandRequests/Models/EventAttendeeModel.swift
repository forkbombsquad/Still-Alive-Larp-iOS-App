//
//  EventAttendeeModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/21/23.
//

import Foundation

struct EventAttendeeModel: CustomCodeable, Identifiable {
    let id: Int
    let playerId: Int
    let characterId: Int?
    let eventId: Int
    let isCheckedIn: String
    let asNpc: String
    let npcId: Int
}

struct EventAttendeeListModel: CustomCodeable {
    let eventAttendees: [EventAttendeeModel]
}

// DO NOT SEND CHARACTER ID WHEN CREATING. IT WILL GET SET AUTOMATICALLY WHEN CHECKING CHAR IN.
struct EventAttendeeCreateModel: CustomCodeable {
    let playerId: Int
    var characterId: Int? = nil
    let eventId: Int
    let isCheckedIn: String
    let asNpc: String
    let npcId: Int
}
