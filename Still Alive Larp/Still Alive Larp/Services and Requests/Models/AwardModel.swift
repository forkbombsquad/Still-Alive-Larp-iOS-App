//
//  AwardModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/13/23.
//

import Foundation

struct AwardModel: CustomCodeable, Identifiable, Equatable {
    let id: Int
    let playerId: Int
    let characterId: Int?
    let awardType: String
    let reason: String
    let date: String
    let amount: String
}

struct AwardCreateModel: CustomCodeable {
    let playerId: Int
    let characterId: Int?
    let awardType: String
    let reason: String
    let date: String
    let amount: String

    static func CreatePlayerAward(_ player: PlayerModel, awardType: AdminService.PlayerAwardType, reason: String, amount: String) -> AwardCreateModel {
        return AwardCreateModel(playerId: player.id, characterId: nil, awardType: awardType.rawValue, reason: reason, date: Date().yyyyMMddFormatted, amount: amount)
    }

    static func CreateCharacterAward(_ character: CharacterModel, awardType: AdminService.CharAwardType, reason: String, amount: String) -> AwardCreateModel {
        return AwardCreateModel(playerId: character.playerId, characterId: character.id, awardType: awardType.rawValue, reason: reason, date: Date().yyyyMMddFormatted, amount: amount)
    }
}

struct AwardListModel: CustomCodeable {
    let awards: [AwardModel]
}
