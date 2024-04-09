//
//  IntrigueService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/26/23.
//

import Foundation

struct IntrigueService {

    static func getIntrigue(_ eventId: Int, onSuccess: @escaping (_ intrigue: IntrigueModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.getIntrigue, addToEndOfUrl: "\(eventId)", responseObject: IntrigueModel.self, overrideDefaultErrorBehavior: true, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
