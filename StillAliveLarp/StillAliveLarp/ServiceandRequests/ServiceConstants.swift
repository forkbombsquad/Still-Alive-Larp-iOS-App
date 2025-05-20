//
//  ServiceConstants.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/3/22.
//

import Foundation

struct ServiceUtils {

    private typealias urls = ServiceUtils.URL

    static func getUrl(_ endpoint: Endpoint) -> String {
        return "\(urls.base)\(urls.apiVersioning)\(endpoint.rawValue)"
    }

    enum Endpoint: String {
        case playerSignInGet = "players/sign_in/"
        case authTokenPost = "auth/login"
        case playerCreatePost = "players/create"
        case announcementsAllGet = "announcements/all_ids/"
        case announcementGet = "announcements/"
    }

    struct URL {
        static let base = "https://stillalivelarp.com/"
        static let apiVersioning = "api/v2/"
    }

    struct OAuth {
        static let secret = "eyJhbGciOiJIUzI1NiJ9.eyJSb2xlIjoiQWRtaW4iLCJJc3N1ZXIiOiJJc3N1ZXIiLCJVc2VybmFtZSI6IkphdmFJblVzZSIsImV4cCI6MTY2NzUwOTE5NSwiaWF0IjoxNjY3NTA5MTk1fQ._EprpsB-1aojuy9JbZdQD5l_qRNPV_FlgDWD1hvvl2Y"
        static let user = "ios_admin@stillalivelarp.com"
        static let pass = "StillAliveIosAppAdmin"
        static let clientId = "iOS App"

        static let oauthBodyParams = [
            "username": user,
            "password": pass,
            "client_id": clientId,
            "client_secret": secret
        ]
    }

}
