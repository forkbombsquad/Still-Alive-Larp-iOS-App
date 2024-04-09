//
//  ContactRequestModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/26/23.
//

import Foundation

struct ContactRequestModel: CustomCodeable, Identifiable {
    let id: Int
    let fullName: String
    let emailAddress: String
    let postalCode: String
    let message: String
    var read: String
}

struct ContactRequestListModel: CustomCodeable {
    let contactRequests: [ContactRequestModel]
}

struct ContactRequestCreateModel: CustomCodeable {
    let fullName: String
    let emailAddress: String
    let postalCode: String
    let message: String
    let read: String
}

