//
//  VersionService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/23/23.
//

import Foundation

struct VersionService {

    static func getVersions(onSuccess: @escaping (_ versions: AppVersionModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.version, responseObject: AppVersionModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
