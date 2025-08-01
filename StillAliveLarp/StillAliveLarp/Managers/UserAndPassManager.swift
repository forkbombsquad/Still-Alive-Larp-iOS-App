//
//  UserAndPassManager.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/4/22.
//

import Foundation

class UserAndPassManager {
    
    fileprivate typealias UPM = UserAndPassManager

    static let shared = UserAndPassManager()

    private static let rememberKey = "remkey"
    private static let ukey = "emanresu"
    private static let pkey = "taxkey"
    
    private static let tempukey = "temp\(UserAndPassManager.ukey)"
    private static let temppkey = "temp\(UserAndPassManager.pkey)"

    private init() {}
    
    func setTemp(u: String, p: String) {
        LocalDataManager.shared.setUnPRelatedObject(key: UPM.tempukey, value: u)
        LocalDataManager.shared.setUnPRelatedObject(key: UPM.temppkey, value: p)
    }
    
    func clearTemp() {
        LocalDataManager.shared.clearUnPRelatedObject(key: UPM.tempukey)
        LocalDataManager.shared.clearUnPRelatedObject(key: UPM.temppkey)
    }
    
    private func clear() {
        LocalDataManager.shared.clearUnPRelatedObject(key: UPM.ukey)
        LocalDataManager.shared.clearUnPRelatedObject(key: UPM.pkey)
        LocalDataManager.shared.clearUnPRelatedObject(key: UPM.rememberKey)
    }
    
    func clearAll() {
        clear()
        clearTemp()
    }
    
    func setUandP(u: String, p: String, remember: Bool) {
        LocalDataManager.shared.setUnPRelatedObject(key: UPM.ukey, value: u)
        LocalDataManager.shared.setUnPRelatedObject(key: UPM.pkey, value: p)
        LocalDataManager.shared.setUnPRelatedObject(key: UPM.rememberKey, value: remember.stringValue)
    }
    
    func getU() -> String? {
        return LocalDataManager.shared.getUnPRelatedObject(key: UPM.ukey)
    }
    
    func getP() -> String? {
        return LocalDataManager.shared.getUnPRelatedObject(key: UPM.pkey)
    }
    
    func getRemember() -> Bool {
        return (LocalDataManager.shared.getUnPRelatedObject(key: UPM.rememberKey) ?? "").boolValueDefaultFalse
    }
    
    func getTempU() -> String? {
        return LocalDataManager.shared.getUnPRelatedObject(key: UPM.tempukey)
    }
    
    func getTempP() -> String? {
        return LocalDataManager.shared.getUnPRelatedObject(key: UPM.temppkey)
    }

}
