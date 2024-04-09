//
//  PlayerManager.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/11/22.
//

import Foundation

class PlayerManager {

    static func forceReset() {
        shared.player = nil
    }

    static let shared = PlayerManager()

    private init() {}

    private var player: PlayerModel?

    func setPlayer(_ player: PlayerModel, fetchChars: Bool = true) {
        self.player = player
        if let p = self.player {
            LocalDataHandler.shared.storePlayer(p)
        }
    }

    func getPlayer() -> PlayerModel? {
        return player
    }

    // Updates Player Locally
    func updatePlayer(_ updatedPlayer: PlayerModel) {
        self.player = updatedPlayer
        if let p = self.player {
            LocalDataHandler.shared.storePlayer(p)
        }
    }

}
