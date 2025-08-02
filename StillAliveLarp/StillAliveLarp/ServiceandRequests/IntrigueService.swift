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

    static func getAllIntrigues(onSuccess: @escaping (_ intrigue: IntrigueListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.getAllIntrigue, responseObject: IntrigueListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }
    
}
