//
//  EventPreregService.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/15/23.
//

import Foundation

struct ResearchProjectService {

    static func getResearchProject(_ projectId: Int, onSuccess: @escaping (_ project: ResearchProjectModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.getResearchProject, addToEndOfUrl: "\(projectId)", responseObject: ResearchProjectModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

    static func getAllResearchProjects(onSuccess: @escaping (_ projectList: ResearchProjectListModel) -> Void, failureCase: @escaping FailureCase) {
        ServiceController.makeRequest(.getAllResearchProjects, responseObject: ResearchProjectListModel.self, success: { success in
            onSuccess(success.jsonObject)
        }, failureCase: failureCase)
    }

}
