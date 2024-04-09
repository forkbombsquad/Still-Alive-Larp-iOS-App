//
//  UserAndPassManager.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/4/22.
//

import Foundation

class UserAndPassManager {

    static func forceReset() {
        UserDefaults.standard.removeObject(forKey: "temp\(shared.ukey)")
        UserDefaults.standard.removeObject(forKey: "temp\(shared.pkey)")
        UserDefaults.standard.removeObject(forKey: shared.ukey)
        UserDefaults.standard.removeObject(forKey: shared.pkey)
    }

    static let shared = UserAndPassManager()

    private let rememberKey = "remkey"
    private let ukey = "emanresu"
    private let pkey = "taxkey"

    private init() {}

    func setTemp(_ u: String, p: String) {
        UserDefaults.standard.set(u, forKey: "temp\(ukey)")
        UserDefaults.standard.set(p, forKey: "temp\(pkey)")
    }

    func setUAndP(_ u: String, p: String, remember: Bool) {
        UserDefaults.standard.set(u, forKey: ukey)
        UserDefaults.standard.set(p, forKey: pkey)
        UserDefaults.standard.set(remember, forKey: rememberKey)
    }

    func getU() -> String? {
        UserDefaults.standard.string(forKey: ukey)
    }

    func getP() -> String? {
        UserDefaults.standard.string(forKey: pkey)
    }

    func remember() -> Bool {
        UserDefaults.standard.bool(forKey: rememberKey)
    }

    func getTempU() -> String? {
        let u = UserDefaults.standard.string(forKey: "temp\(ukey)")
        UserDefaults.standard.removeObject(forKey: "temp\(ukey)")
        return u
    }

    func getTempP() -> String? {
        let p = UserDefaults.standard.string(forKey: "temp\(pkey)")
        UserDefaults.standard.removeObject(forKey: "temp\(pkey)")
        return p
    }

}
