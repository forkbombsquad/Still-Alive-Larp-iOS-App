//
//  EventAttendeeService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/27/23.
//

import Foundation

struct EventAttendeeService {

    static func getEventsForPlayer(_ playerId: Int, onSuccess: @escaping (_ attendeeList: EventAttendeeListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.eventAttendeesForPlayer, addToEndOfUrl: "\(playerId)", responseObject: EventAttendeeListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func deleteAttendees(onSuccess: @escaping (_ attendeeList: EventAttendeeListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.deleteEventAttendee, responseObject: EventAttendeeListModel.self, overrideDefaultErrorBehavior: true, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
