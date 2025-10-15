//
//  EventPreregService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/15/23.
//

import Foundation

struct EventPreregService {

    static func getPreregsForEvent(_ eventId: Int, onSuccess: @escaping (_ preregList: EventPreregListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.allPreregsForEvent, addToEndOfUrl: "\(eventId)", responseObject: EventPreregListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func preregPlayer(_ preregCreateModel: EventPreregCreateModel, onSuccess: @escaping (_ prereg: EventPreregModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.prereg, bodyJson: preregCreateModel, responseObject: EventPreregModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func updatePrereg(_ preregModel: EventPreregModel, onSuccess: @escaping (_ prereg: EventPreregModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.updatePrereg, bodyJson: preregModel, responseObject: EventPreregModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func deletePreregs(onSuccess: @escaping (_ preregList: EventPreregListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.deleteEventPreregs, responseObject: EventPreregListModel.self, overrideDefaultErrorBehavior: true, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }
    
    static func getAllPreregs(onSuccess: @escaping (_ preregList: EventPreregListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.allPreregs, responseObject: EventPreregListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
