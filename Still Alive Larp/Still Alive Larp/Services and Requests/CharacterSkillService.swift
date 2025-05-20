//
//  PlayerSkillService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/14/23.
//

import Foundation

struct CharacterSkillService {

    static func getAllSkillsForChar(_ characterId: Int, onSuccess: @escaping (_ charSkills: CharacterSkillListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.getAllSkillsForChar, addToEndOfUrl: "\(characterId)", responseObject: CharacterSkillListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func takeSkill(_ charSkillModel: CharacterSkillCreateModel, playerId: Int, onSuccess: @escaping (_ updatedPlayer: PlayerModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.takeSkill, addToEndOfUrl: "\(playerId)", bodyJson: charSkillModel, responseObject: PlayerModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }
    
    static func takePlannedCharacterSkill(_ charSkillModel: CharacterSkillCreateModel, onSuccess: @escaping (_ charSkill: CharacterSkillModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.createPlannedCharacterSkill, bodyJson: charSkillModel, responseObject: CharacterSkillModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)

    }

    static func deleteSkills(characterId: Int, onSuccess: @escaping (_ charSkills: CharacterSkillListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.deleteSkills, addToEndOfUrl: "\(characterId)", responseObject: CharacterSkillListModel.self, overrideDefaultErrorBehavior: true, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
