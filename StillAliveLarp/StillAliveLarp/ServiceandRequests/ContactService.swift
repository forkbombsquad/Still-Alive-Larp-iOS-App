//
//  ContactService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/26/23.
//

import Foundation

struct ContactService {

    static func createContactRequest(_ contactRequest: ContactRequestCreateModel, onSuccess: @escaping (_ contactRequest: ContactRequestModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.createContact, bodyJson: contactRequest, responseObject: ContactRequestModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
