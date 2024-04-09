//
//  SkillService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/11/23.
//

import Foundation

struct SkillService {

    static func getSkill(_ skillId: Int, onSuccess: @escaping (_ skillModel: SkillModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.skill, addToEndOfUrl: "\(skillId)", responseObject: SkillModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)

    }

    static func getAllSkills(onSuccess: @escaping (_ skillListModel: SkillListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.allSkills, responseObject: SkillListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
