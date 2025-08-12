//
//  OldLocalDataHandler.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/21/23.
//

import Foundation
import UIKit

// TODO remove this boi completely

class OldLocalDataHandler {
//
//    struct Keys {
//        static let playerKey = "player_ud_key"
//        static let characterKey = "character_ud_key"
//        static let gearKey = "gear_ud_key"
//        static let rulebookKey = "rulebook_ud_key"
//        static let rulebookVersionKey = "rulebook_version_ud_key"
//        static let skillsKey = "skills_ud_key"
//        static let npcKey = "npcs_ud_key"
//        static let categoriesKey = "categories_ud_key"
//
//        static let allKeys: [String] = [playerKey, characterKey, gearKey, rulebookKey, rulebookVersionKey, skillsKey, npcKey, categoriesKey]
//    }
//
//    static func forceReset() {
//        for key in Keys.allKeys {
//            UserDefaults.standard.removeObject(forKey: key)
//        }
//    }
//
//    static let shared = OldLocalDataHandler()
//
//    private init() {}
//
//    func storePlayer(_ player: PlayerModel) {
//        guard let json = player.toData() else { return }
//        UserDefaults.standard.set(json, forKey: Keys.playerKey)
//    }
//
//    func getPlayer() -> PlayerModel? {
//        guard let json = UserDefaults.standard.data(forKey: Keys.playerKey), let player: PlayerModel = json.toJsonObject() else { return nil }
//        return player
//    }
//
//    func storeCharacter(_ character: FullCharacterModel) {
//        guard let json = character.toData() else { return }
//        UserDefaults.standard.set(json, forKey: Keys.characterKey)
//    }
//
//    func getCharacter() -> FullCharacterModel? {
//        guard let json = UserDefaults.standard.data(forKey: Keys.characterKey), let character: FullCharacterModel = json.toJsonObject() else { return nil }
//        return character
//    }
//
//    func storeGear(_ gearList: GearListModel) {
//        guard let json = gearList.toData() else { return }
//        UserDefaults.standard.set(json, forKey: Keys.gearKey)
//    }
//
//    func getGear() -> [GearModel]? {
//        guard let json = UserDefaults.standard.data(forKey: Keys.gearKey), let gearList: GearListModel = json.toJsonObject() else { return nil }
//        return gearList.charGear
//    }
//
//    func getRulebookVersion() -> String? {
//        return UserDefaults.standard.string(forKey: Keys.rulebookVersionKey)
//    }
//
//    func storeRulebookVersion(_ version: String) {
//        UserDefaults.standard.set(version, forKey: Keys.rulebookVersionKey)
//    }
//
//    func getRulebook() -> String? {
//        return UserDefaults.standard.string(forKey: Keys.rulebookKey)
//    }
//
//    func storeRulebook(_ rulebook: String) {
//        UserDefaults.standard.set(rulebook, forKey: Keys.rulebookKey)
//    }
//
//    func storeImageData(_ data: Data, key: String) {
//        UserDefaults.standard.set(data, forKey: key)
//    }
//
//    func getImage(_ key: ImageDownloader.ImageKey) -> UIImage? {
//        guard let data = UserDefaults.standard.data(forKey: key.rawValue) else { return nil }
//        return UIImage(data: data)
//    }
//
//    func storeSkills(_ skills: [FullCharacterModifiedSkillModel]) {
//        let fslm = SKillListModel(skills: skills)
//        guard let json = fslm.toData() else { return }
//        UserDefaults.standard.set(json, forKey: Keys.skillsKey)
//    }
//
//    func getSkills() -> [FullCharacterModifiedSkillModel]? {
//        guard let json = UserDefaults.standard.data(forKey: Keys.skillsKey), let skillM: FullSkillListModel = json.toJsonObject() else { return nil }
//        return skillM.skills
//    }
//
//    func storeNPCs(_ npcs: [FullCharacterModel]) {
//        let fclm = FullCharacterListModel(characters: npcs)
//        guard let json = fclm.toData() else { return }
//        UserDefaults.standard.set(json, forKey: Keys.npcKey)
//    }
//
//    func getNPCs() -> [FullCharacterModel]? {
//        guard let json = UserDefaults.standard.data(forKey: Keys.npcKey), let npcM: FullCharacterListModel = json.toJsonObject() else { return nil }
//        return npcM.characters
//    }
//
//    func storeSkillCategories(_ skillCategories: SKillCategoryListModel) {
//        guard let json = skillCategories.toData() else { return }
//        UserDefaults.standard.set(json, forKey: Keys.categoriesKey)
//    }
//
//    func getSkillCategories() -> [SkillCategoryModel]? {
//        guard let json = UserDefaults.standard.data(forKey: Keys.categoriesKey), let categories: SKillCategoryListModel = json.toJsonObject() else { return nil }
//        return categories.results
//    }
//
}
