//
//  FeatureFlagModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/18/24.
//

import Foundation

struct FeatureFlagModel: CustomCodeable {
    let id: Int
    let name: String
    let description: String
    let activeAndroid: String
    let activeIos: String

    var isActiveIos: Bool {
        return activeIos.boolValueDefaultFalse
    }

    var isActiveAndroid: Bool {
        return activeAndroid.boolValueDefaultFalse
    }
}

struct FeatureFlagCreateModel: CustomCodeable {
    let name: String
    let description: String
    let activeAndroid: String
    let activeIos: String
}

struct FeatureFlagListModel: CustomCodeable {
    var results: [FeatureFlagModel]
}
