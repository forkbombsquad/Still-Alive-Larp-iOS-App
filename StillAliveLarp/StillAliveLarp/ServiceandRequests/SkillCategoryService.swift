//
//  SkillCategoryService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/16/25.
//

struct SkillCategoryService {

    static func getAllSkillCategories(onSuccess: @escaping (_ skillCategories: SKillCategoryListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.getAllSkillCategories, responseObject: SKillCategoryListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)

    }

}
