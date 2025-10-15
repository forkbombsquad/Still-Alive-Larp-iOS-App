//
//  LocalDataManagerModels.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 7/25/25.
//

import Foundation

struct LDAwardModels: CustomCodeable {
    let playerAwards: [Int : [AwardModel]]
    let characterAwards: [Int : [AwardModel]]
}

struct LDEventAttendeeModels: CustomCodeable {
    let byEvent: [Int : [EventAttendeeModel]]
    let byPlayer: [Int : [EventAttendeeModel]]
    let byCharacter: [Int : [EventAttendeeModel]]
}

struct LDPreregModels: CustomCodeable {
    let byEvent: [Int : [EventPreregModel]]
    let byPlayer: [Int : [EventPreregModel]]
    let byCharacter: [Int : [EventPreregModel]]
    let byRegType: [EventRegType : [EventPreregModel]]
}

struct LDSkillPrereqModels: CustomCodeable {
    let all: [SkillPrereqModel]
    let byBaseSkill: [Int : [SkillPrereqModel]]
    let byPrereqSkill: [Int : [SkillPrereqModel]]
}

struct LDImageDataModel: CustomCodeable {
    let imageData: Data
}
