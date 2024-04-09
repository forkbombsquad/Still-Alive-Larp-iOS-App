//
//  IntrigueModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/26/23.
//

import Foundation

struct IntrigueModel: CustomCodeable, Identifiable {
    let id: Int
    let eventId: Int
    var investigatorMessage: String
    var interrogatorMessage: String
    var webOfInformantsMessage: String
}

struct IntrigueListModel: CustomCodeable {
    let intrigues: [IntrigueModel]
}

struct IntrigueCreateModel: CustomCodeable {
    let eventId: Int
    let investigatorMessage: String
    let interrogatorMessage: String
    let webOfInformantsMessage: String
}
