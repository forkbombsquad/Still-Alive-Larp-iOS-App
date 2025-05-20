//
//  PlayerCheckInBarcodeModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/20/23.
//

import Foundation


struct PlayerCheckInBarcodeModel: CustomCodeable {

    var player: PlayerBarcodeModel
    var character: CharacterBarcodeModel?
    var event: EventBarcodeModel
    var relevantSkills: [SkillBarcodeModel]
    var gear: GearModel?

}

struct PlayerCheckOutBarcodeModel: CustomCodeable {
    var player: PlayerBarcodeModel
    var character: CharacterBarcodeModel?
    var eventAttendeeId: Int
    var eventId: Int
    var relevantSkills: [SkillBarcodeModel]
}
