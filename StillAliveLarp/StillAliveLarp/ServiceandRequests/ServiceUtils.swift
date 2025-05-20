//
//  ServiceConstants.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/3/22.
//

import Foundation

struct ServiceUtils {

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
