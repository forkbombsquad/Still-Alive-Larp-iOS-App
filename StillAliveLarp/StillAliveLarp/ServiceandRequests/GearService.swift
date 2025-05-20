//
//  GearService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 6/20/23.
//

import Foundation

struct GearService {

    static func getAllGear(onSuccess: @escaping (_ gearListModel: GearListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.allGear, responseObject: GearListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func getAllGearForCharacter(characterId: Int, onSuccess: @escaping (_ gearListModel: GearListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.allGearForChar, addToEndOfUrl: characterId.stringValue, responseObject: GearListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func deleteGear(characterId: Int, onSuccess: @escaping (_ gearModel: GearModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.deleteGear, addToEndOfUrl: characterId.stringValue, responseObject: GearModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
