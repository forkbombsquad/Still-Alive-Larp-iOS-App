//
//  UpdateTrackerService.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 7/25/25.
//

import Foundation

struct UpdateTrackerService {

    static func getUpdateTracker(onSuccess: @escaping (_ updateTrackerModel: UpdateTrackerModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.updateTracker, responseObject: UpdateTrackerModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
