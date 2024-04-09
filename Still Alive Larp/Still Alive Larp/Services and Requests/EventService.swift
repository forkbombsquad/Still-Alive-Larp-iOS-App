//
//  EventService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/19/23.
//

import Foundation

struct EventService {

    static func getAllEvents(onSuccess: @escaping (_ eventList: EventListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.allEvents, responseObject: EventListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)

    }

}
