//
//  SkillPrereqService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/12/23.
//

import Foundation

struct SkillPrereqService {

    static func getSkillPrereqs(_ skillId: Int, onSuccess: @escaping (_ skillPrereqListModel: SkillPrereqListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.skillPrereqsForId, addToEndOfUrl: "\(skillId)", responseObject: SkillPrereqListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)

    }

    static func getAllSkillPrereqs(onSuccess: @escaping (_ skillPrereqListModel: SkillPrereqListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.allSkillPrereqs, responseObject: SkillPrereqListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
