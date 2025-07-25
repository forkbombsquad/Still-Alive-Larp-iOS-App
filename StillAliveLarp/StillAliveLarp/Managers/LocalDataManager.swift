//
//  LocalDataManager.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 7/25/25.
//

import Foundation

class LocalDataManager {
    
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
    
    private func get<T: Decodable>(_ key: String) -> T? {
        guard let compressed = UserDefaults.standard.data(forKey: getUserDefaultsKey(key)) else { return nil }
        guard let json = compressed.decompress() else { return nil }
        guard let obj: T = json.toJsonObject(as: T.self) else { return nil }
        return obj
    }
    
    private func get<T: Decodable>(_ key: DMT) -> T? {
        return get(key.getLocalDataKey())
    }
    
}
