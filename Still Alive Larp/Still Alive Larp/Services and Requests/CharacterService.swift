//
//  CharacterService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/11/22.
//

import Foundation

struct CharacterService {

    static func getCharacter(_ characterId: Int, onSuccess: @escaping (_ characterModel: CharacterModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.character, addToEndOfUrl: "\(characterId)", responseObject: CharacterModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)

    }

    static func createCharacter(_ character: CreateCharacterModel, onSuccess: @escaping (_ characterModel: CharacterModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.characterCreate, bodyJson: character, responseObject: CharacterModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)

    }

    static func updateBio(_ character: CharacterModel, onSuccess: @escaping (_ characterModel: CharacterModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.updateBio, bodyJson: character, responseObject: CharacterModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)

    }

    static func getAllPlayerCharacters(_ playerId: Int, onSuccess: @escaping (_ characterListModel: CharacterListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.charactersForPlayer, params: ["player_id_in" : playerId], responseObject: CharacterListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func getAllCharacters(onSuccess: @escaping (_ characterList: CharacterListFullModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.allCharacters, responseObject: CharacterListFullModel.self, success: { success in
            var jsonObject = success.jsonObject
            jsonObject.characters = success.jsonObject.characters.filter({ $0.fullName.lowercased() != "google test" })
            onSuccess(jsonObject)
        }, failureCase: failureCase)

    }

    static func deleteCharacters(onSuccess: @escaping (_ characterList: CharacterListFullModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.deleteCharacters, responseObject: CharacterListFullModel.self, overrideDefaultErrorBehavior: true, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
