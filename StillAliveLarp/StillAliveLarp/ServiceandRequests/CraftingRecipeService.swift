//
//  CraftingRecipeService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/17/26.
//

import Foundation

struct CraftingRecipeService {

    static func getAllCraftingRecipes(onSuccess: @escaping (_ list: CraftingRecipeListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.getAllCraftingRecipes, responseObject: CraftingRecipeListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}