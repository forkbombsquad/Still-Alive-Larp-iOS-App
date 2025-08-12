//
//  PlayerService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/13/23.
//

import Foundation

struct PlayerService {

    static func getAllPlayers(onSuccess: @escaping (_ playerList: PlayerListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.allPlayers, responseObject: PlayerListModel.self, success: { success in
            var jsonObject = success.jsonObject
            jsonObject.players = success.jsonObject.players.filter({ $0.username.lowercased() != "googletestaccount@gmail.com"})
            onSuccess(jsonObject)
        }, failureCase: failureCase)

    }

    static func getPlayer( _ playerId: Int, onSuccess: @escaping (_ player: PlayerModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.player, addToEndOfUrl: "\(playerId)", responseObject: PlayerModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)

    }

    static func signInPlayer(onSuccess: @escaping (_ player: PlayerModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.playerSignIn, responseObject: PlayerModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func createPlayer(_ preApprovalCode: String, player: PlayerCreateModel, onSuccess: @escaping (_ player: PlayerModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.playerCreate, headers: ["preapprovalcode": preApprovalCode], bodyJson: player, responseObject: PlayerModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func updateP(_ newP: String, playerId: Int, onSuccess: @escaping (_ player: PlayerModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.updateP, addToEndOfUrl: "\(playerId)", headers: ["p": newP], responseObject: PlayerModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func deletePlayer(onSuccess: @escaping (_ player: PlayerModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.deletePlayer, responseObject: PlayerModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
