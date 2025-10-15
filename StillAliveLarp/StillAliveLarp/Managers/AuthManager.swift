//
//  AuthManager.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/3/22.
//

import Foundation

class AuthManager {

    static let shared = AuthManager()

    private var token: String?
    private var tokenExpireDate: Date?
    
    private var playerToken: String?
    private var playerTokenExpireDate: Date?

    private let tokenKey = "udtokenkey"
    private let tokenDateKey = "udtokendatekey"

    private let tokenExpireDays = 6

    private init() { }

    func forceRefreshToken() {
        setTokenInUd(nil, date: nil)
        token = nil
        tokenExpireDate = nil
        playerToken = nil
        playerTokenExpireDate = nil
    }

    func getAuthToken(_ callback: @escaping (_ token: String?) -> Void) {
        if tokenIsExpired() {
            globalPrintServiceLogs("Token Expired, Fetching New Token")
            ServiceController.makeRequest(.authToken, contentType: .urlEncoded, headers: ["accept": ServiceController.ContentType.json.rawValue], bodyParams: ServiceUtils.OAuth.oauthBodyParams, responseObject: OAuthTokenResponse.self, sendToken: false, sendUserAndPass: false, sendPlayerToken: false) { success in
                self.token = success.jsonObject.access_token
                self.tokenExpireDate = self.getTokenExpireDate()
                self.setTokenInUd()
                callback(self.token)
                return
            } failureCase: { error in
                self.token = nil
                self.tokenExpireDate = nil
                UserDefaults.standard.removeObject(forKey: self.tokenDateKey)
                UserDefaults.standard.removeObject(forKey: self.tokenKey)
                callback(nil)
                return
            }

        } else {
            globalPrintServiceLogs("Reusing Token")
            callback(token)
        }
    }
    
    func getPlayerToken(_ callback: @escaping (_ playerToken: String?) -> Void) {
        if playerTokenIsExpired() || playerToken == nil {
            globalPrintServiceLogs("Fetching Player Token...")
            ServiceController.makeRequest(.playerAuthToken, contentType: .urlEncoded, headers: ["accept": ServiceController.ContentType.json.rawValue], responseObject: OAuthTokenResponse.self, sendToken: true, sendUserAndPass: true, sendPlayerToken: false) { success in
                self.playerToken = success.jsonObject.access_token
                self.playerTokenExpireDate = self.getPlayerTokenExpireDate()
                callback(self.playerToken)
                return
            } failureCase: { error in
                self.playerToken = nil
                self.playerTokenExpireDate = nil
                callback(nil)
                return
            }
        } else {
            globalPrintServiceLogs("Reusing Player Token")
            callback(playerToken)
        }
    }

    private func setTokenInUd() {
        UserDefaults.standard.set(token, forKey: self.tokenKey)
        UserDefaults.standard.set(tokenExpireDate, forKey: self.tokenDateKey)
    }

    private func setTokenInUd(_ token: String?, date: Date?) {
        UserDefaults.standard.set(token, forKey: self.tokenKey)
        UserDefaults.standard.set(date, forKey: self.tokenDateKey)
    }

    private func getTokenExpireDate() -> Date {
        let currentDate = Date()
        var components = DateComponents()

        components.day = tokenExpireDays
        return Calendar.current.date(byAdding: components, to: currentDate) ?? currentDate
    }
    
    private func getPlayerTokenExpireDate() -> Date {
        let currentDate = Date()
        var components = DateComponents()

        components.day = tokenExpireDays
        return Calendar.current.date(byAdding: components, to: currentDate) ?? currentDate
    }
    
    private func playerTokenIsExpired() -> Bool {
        guard playerToken != nil, let pted = playerTokenExpireDate else { return true }
        let currentDate = Date.now
        return currentDate > pted
    }

    private func tokenIsExpired() -> Bool {
        if token == nil && tokenExpireDate == nil {
            token = UserDefaults.standard.string(forKey: tokenKey)
            tokenExpireDate = UserDefaults.standard.object(forKey: tokenDateKey) as? Date
        }
        guard token != nil, let ted = tokenExpireDate else { return true }
        let currentDate = Date.now
        return currentDate > ted
    }



}
