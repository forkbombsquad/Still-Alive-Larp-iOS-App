//
//  AwardService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/13/23.
//

import Foundation

struct AwardService {

    static func getAllAwards(onSuccess: @escaping (_ awardList: AwardListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.awards, responseObject: AwardListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func getAwardsForPlayer(_ playerId: Int, onSuccess: @escaping (_ awardList: AwardListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.awards, addToEndOfUrl: "\(playerId)", responseObject: AwardListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func deleteAwards(onSuccess: @escaping (_ awardList: AwardListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.deleteAwards, responseObject: AwardListModel.self, overrideDefaultErrorBehavior: true, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
