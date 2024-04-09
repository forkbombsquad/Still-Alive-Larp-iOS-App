//
//  LocalDataHandler.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/21/23.
//

import Foundation

class LocalDataHandler {

    struct Keys {
        static let playerKey = "player_ud_key"
        static let characterKey = "character_ud_key"
        static let gearKey = "gear_ud_key"
        static let rulebookKey = "rulebook_ud_key"
        static let rulebookVersionKey = "rulebook_version_ud_key"
    }

    static func forceReset() {
        UserDefaults.standard.removeObject(forKey: Keys.playerKey)
        UserDefaults.standard.removeObject(forKey: Keys.characterKey)
        UserDefaults.standard.removeObject(forKey: Keys.gearKey)
    }

    static let shared = LocalDataHandler()

    private init() {}

    func storePlayer(_ player: PlayerModel) {
        guard let json = player.toData() else { return }
        UserDefaults.standard.set(json, forKey: Keys.playerKey)
    }

    func getPlayer() -> PlayerModel? {
        guard let json = UserDefaults.standard.data(forKey: Keys.playerKey), let player: PlayerModel = json.toJsonObject() else { return nil }
        return player
    }

    func storeCharacter(_ character: FullCharacterModel) {
        guard let json = character.toData() else { return }
        UserDefaults.standard.set(json, forKey: Keys.characterKey)
    }

    func getCharacter() -> FullCharacterModel? {
        guard let json = UserDefaults.standard.data(forKey: Keys.characterKey), let character: FullCharacterModel = json.toJsonObject() else { return nil }
        return character
    }

    func storeGear(_ gearList: GearListModel) {
        guard let json = gearList.toData() else { return }
        UserDefaults.standard.set(json, forKey: Keys.gearKey)
    }

    func getGear() -> [GearModel]? {
        guard let json = UserDefaults.standard.data(forKey: Keys.gearKey), let gearList: GearListModel = json.toJsonObject() else { return nil }
        return gearList.charGear
    }

    func getRulebookVersion() -> String? {
        return UserDefaults.standard.string(forKey: Keys.rulebookVersionKey)
    }

    func storeRulebookVersion(_ version: String) {
        UserDefaults.standard.set(version, forKey: Keys.rulebookVersionKey)
    }

    func getRulebook() -> String? {
        return UserDefaults.standard.string(forKey: Keys.rulebookKey)
    }

    func storeRulebook(_ rulebook: String) {
        UserDefaults.standard.set(rulebook, forKey: Keys.rulebookKey)
    }

}
