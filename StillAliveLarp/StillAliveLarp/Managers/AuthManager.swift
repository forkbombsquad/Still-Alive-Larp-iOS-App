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

    private let tokenKey = "udtokenkey"
    private let tokenDateKey = "udtokendatekey"

    private let tokenExpireDays = 6

    private init() { }

    func forceRefreshToken() {
        setTokenInUd(nil, date: nil)
        token = nil
        tokenExpireDate = nil
    }

    func getAuthToken(_ callback: @escaping (_ token: String?) -> Void) {
        if tokenIsExpired() {
            globalPrintServiceLogs("Token Expired, Fetching New Token")
            ServiceController.makeRequest(.authToken, contentType: .urlEncoded, headers: ["accept": ServiceController.ContentType.json.rawValue], bodyParams: ServiceUtils.OAuth.oauthBodyParams, responseObject: OAuthTokenResponse.self, sendToken: false, sendUserAndPass: false) { success in
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
