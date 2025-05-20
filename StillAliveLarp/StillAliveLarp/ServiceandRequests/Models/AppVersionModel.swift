//
//  AppVersionModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/23/23.
//

import Foundation

struct AppVersionModel: CustomCodeable {
    let androidVersion: Int
    var iosVersion: Int
    var rulebookVersion: String
}
