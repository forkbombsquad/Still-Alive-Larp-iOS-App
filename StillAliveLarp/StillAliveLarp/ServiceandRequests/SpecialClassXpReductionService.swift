//
//  SpecialClassXpReductionService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/29/23.
//

import Foundation

struct SpecialClassXpReductionService {

    static func getXpReductionsForCharacter(_ characterId: Int, onSuccess: @escaping (_ xpReductions: XpReductionListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.getXpReductionsForChar, addToEndOfUrl: "\(characterId)", responseObject: XpReductionListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }
    
    static func getAllXpReductions(onSuccess: @escaping (_ xpReductions: XpReductionListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.getAllXpReductions, responseObject: XpReductionListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func deleteXpReductions(characterId: Int, onSuccess: @escaping (_ xpReductions: XpReductionListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.deleteXpRedsForChar, addToEndOfUrl: "\(characterId)", responseObject: XpReductionListModel.self, overrideDefaultErrorBehavior: true, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
