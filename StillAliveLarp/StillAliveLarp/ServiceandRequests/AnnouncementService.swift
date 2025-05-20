//
//  AnnouncementService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/15/23.
//

import Foundation

struct AnnouncementService {

    static func getAnnouncement(_ id: Int, onSuccess: @escaping (_ announcement: AnnouncementModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.announcement, addToEndOfUrl: "\(id)", responseObject: AnnouncementModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
