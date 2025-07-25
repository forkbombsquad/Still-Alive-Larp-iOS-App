//
//  LocalDataManager.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 7/25/25.
//

import Foundation

class LocalDataManager {
    
    struct CollectionCompressorObject<C>: CustomCodeable, Identifiable where C: Collection & Codable, C.Element: Codable {
        var id = UUID()
        let collection: C
    }
    
    private typealias DMT = DataManager.DataManagerType
    
    private class LDMKeys {
        static let ldmkeysPostfix = "_LDMKEYS_dm_ud_key"
        static let unpUserDefaultsKey = "StillAliveLarpUserDefaults"
        static let sharedPrefsBaseKey = "StillALiveLarpLocalDataPrefBaseKey"
        static let fullSkillsKey = "fullskills\(ldmkeysPostfix)"
        static let fullEventsKey = "fullevents\(ldmkeysPostfix)"
        static let fullCharactersKey = "fullcharacters\(ldmkeysPostfix)"
        static let fullPlayersKey = "fullplayers\(ldmkeysPostfix)"
        static let playerIdKey = "playerid\(ldmkeysPostfix)"
        
        static let allKeys = [fullSkillsKey, fullEventsKey, fullCharactersKey, fullPlayersKey, playerIdKey]
    }
    
    static let shared = LocalDataManager()
    
    // TODO ROUTINE - update this number if any of the models change between releases
    static let localDataVersion = "1.0.0.0"
    
    static func clearAllLocalData() {
        // TODO
        // UserAndPassManager.shared.clearAll()
        for key in LDMKeys.allKeys {
            shared.clear(key)
        }
        for type in DMT.allCases {
            shared.clear(type)
        }
    }
    
    private init() {}
    
    //
    // MARK: - Utils and Generics
    //
    
    private func getUnPUserDefaultsKey(_ key: String) -> String {
        return LDMKeys.unpUserDefaultsKey + "_\(key)"
    }
    
    func setUnPRelatedObject(key: String, value: String) {
        UserDefaults.standard.set(value, forKey: getUnPUserDefaultsKey(key))
    }
    
    private func getUnPRelatedObject(key: String) -> String? {
        return UserDefaults.standard.string(forKey: getUnPUserDefaultsKey(key))
    }
    
    private func getUserDefaultsKey(_ key: String) -> String {
        return LDMKeys.sharedPrefsBaseKey + LocalDataManager.localDataVersion + "_\(key)"
    }
    
    private func getUserDefaultsKey(_ key: DMT) -> String {
        return  getUserDefaultsKey(key.getLocalDataKey())
    }
    
    private func clear(_ key: String) {
        UserDefaults.standard.removeObject(forKey: getUserDefaultsKey(key))
    }
    
    private func clear(_ key: DMT) {
        clear(key.getLocalDataKey())
    }
    
    private func store(_ obj: CustomCodeable, key: String) {
        let json = obj.toJsonString() ?? ""
        let compressed = json.compress()
        UserDefaults.standard.set(compressed, forKey: getUserDefaultsKey(key))
    }
    
    private func store(_ obj: CustomCodeable, key: DMT) {
        store(obj, key: key.getLocalDataKey())
    }
    
    private func store<C>(_ obj: C, key: String) where C: Collection & Codable, C.Element: Codable {
        let collectionCompressor = CollectionCompressorObject(collection: obj)
        store(collectionCompressor, key: key)
    }
    
    private func store<C>(_ obj: C, key: DMT) where C: Collection & Codable, C.Element: Codable {
        store(obj, key: key.getLocalDataKey())
    }
    
    private func get<T: CustomCodeable>(_ key: String) -> T? {
        guard let compressed = UserDefaults.standard.data(forKey: getUserDefaultsKey(key)) else { return nil }
        guard let json = compressed.decompress() else { return nil }
        guard let obj: T = json.toJsonObject(as: T.self) else { return nil }
        return obj
    }
    
    private func get<T: CustomCodeable>(_ key: DMT) -> T? {
        return get(key.getLocalDataKey())
    }
    
    private func get<C>(_ key: String) -> C? where C: Collection & Codable, C.Element: CustomCodeable {
        guard let compressed = UserDefaults.standard.data(forKey: getUserDefaultsKey(key)) else { return nil }
        guard let json = compressed.decompress() else { return nil }
        guard let wrapper: CollectionCompressorObject<C> = json.toJsonObject() else { return nil }
        return wrapper.collection
    }
    
    private func get<C>(_ key: DMT) -> C? where C: Collection & Codable, C.Element: CustomCodeable {
        return get(key.getLocalDataKey())
    }
    
    //
    // MARK: - storing objects
    //
    
    private func storeUpdateTracker(_ updateTracker: UpdateTrackerModel) {
        store(updateTracker, key: DMT.updateTracker)
    }
    
    private func getUpdateTracker() -> UpdateTrackerModel? {
        return get(DMT.updateTracker)
    }
    
    private func storeAnnouncements(_ announcements: [AnnouncementModel]) {
        store(announcements, key: DMT.announcements)
    }
    
    private func getAnnouncements() -> [AnnouncementModel] {
        return get(DMT.announcements) ?? []
    }
    
    private func storeAwards(awards: [AwardModel]) {
        var playerAwards: [Int : [AwardModel]] = [:]
        var charAwards: [Int : [AwardModel]] = [:]
        
        for award in awards {
            if let charId = award.characterId, charId != -1 {
                charAwards[charId, default: []].append(award)
            } else {
                playerAwards[award.playerId, default: []].append(award)
            }
        }
        let ams = LDAwardModels(playerAwards: playerAwards, characterAwards: charAwards)
        store(ams, key: DMT.awards)
    }
    
    private func getAwards() -> LDAwardModels {
        return get(DMT.awards) ?? LDAwardModels(playerAwards: [:], characterAwards: [:])
    }
    
    private func storeCharacters(_ characters: [CharacterModel]) {
        store(characters, key: DMT.characters)
    }
    
    private func getCharacters() -> [CharacterModel] {
        return get(DMT.characters) ?? []
    }
    
}
