//
//  CampStatusService.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 8/1/25.
//

import Foundation

struct CampStatusService {

    static func getCampStatus(onSuccess: @escaping (_ campStatusModel: CampStatusModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.campStatus, responseObject: CampStatusModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
