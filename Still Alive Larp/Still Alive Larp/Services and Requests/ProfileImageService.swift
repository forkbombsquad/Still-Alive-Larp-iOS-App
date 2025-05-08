//
//  ProfileImageService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/18/24.
//

import Foundation

struct ProfileImageService {

    static func getProfileImage(_ playerId: Int, onSuccess: @escaping (_ profileImage: ProfileImageModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.getProfileImage, addToEndOfUrl: "\(playerId)", responseObject: ProfileImageModel.self, overrideDefaultErrorBehavior: true, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func createProfileImage(_ profileImageCreateModel: ProfileImageCreateModel, onSuccess: @escaping (_ profileImage: ProfileImageModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.createProfileImage, bodyJson: profileImageCreateModel, responseObject: ProfileImageModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func updateProfileImage(_ profileImageModel: ProfileImageModel, onSuccess: @escaping (_ profileImage: ProfileImageModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.updateProfileImage, bodyJson: profileImageModel, responseObject: ProfileImageModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func deleteProfileImage(_ playerId: Int, onSuccess: @escaping (_ profileImage: ProfileImageListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.deleteProfileImage, addToEndOfUrl: "\(playerId)", responseObject: ProfileImageListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
