//
//  FeatureFlagService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/18/24.
//

import Foundation

struct FeatureFlagService {

    static func getFeatureFlag(_ featureFlagId: Int, onSuccess: @escaping (_ featureFlag: FeatureFlagModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.getFeatureFlag, addToEndOfUrl: "\(featureFlagId)", responseObject: FeatureFlagModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func getAllFeatureFlags(onSuccess: @escaping (_ featureFlags: FeatureFlagListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.getAllFeatureFlags, responseObject: FeatureFlagListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
