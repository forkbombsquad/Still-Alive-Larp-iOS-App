//
//  SpecialClassXpReductionService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/29/23.
//

import Foundation

struct SpecialClassXpReductionService {

    static func getXpReductionsForCharacter(_ characterId: Int, onSuccess: @escaping (_ xpReductions: SpecialClassXpReductionListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.getXpReductionsForChar, addToEndOfUrl: "\(characterId)", responseObject: SpecialClassXpReductionListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func deleteXpReductions(characterId: Int, onSuccess: @escaping (_ xpReductions: SpecialClassXpReductionListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.deleteXpRedsForChar, addToEndOfUrl: "\(characterId)", responseObject: SpecialClassXpReductionListModel.self, overrideDefaultErrorBehavior: true, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
