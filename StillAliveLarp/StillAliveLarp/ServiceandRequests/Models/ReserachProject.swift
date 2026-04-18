//
//  ResearchProjectModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/29/25.
//

import Foundation

struct ResearchProjectModel: CustomCodeable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let milestones: Int
    let complete: String
    let milestoneDescs: String

    var milestoneJsonModels: [ResearchProjectMilestoneJsonModel] {
        let listModel = milestoneDescs.data(using: .utf8)?.toJsonObject() as? [String: Any]
        let milestoneDescsArray = listModel?["milestoneDescs"] as? [[String: Any]]
        return milestoneDescsArray?.compactMap { dict in
            guard let id = dict["id"] as? String,
                  let text = dict["text"] as? String else { return nil }
            return ResearchProjectMilestoneJsonModel(id: id, text: text)
        } ?? []
    }

}

struct ResearchProjectListModel: CustomCodeable {
    let researchProjects: [ResearchProjectModel]
}

struct ResearchProjectCreateModel: CustomCodeable {
    let name: String
    let description: String
    let milestones: Int
    let complete: String
    let milestoneDescs: String
}

struct ResearchProjectMilestoneJsonModel: CustomCodeable {
    let id: String
    let text: String
}

struct ResearchProjectMilestoneJsonListModel: CustomCodeable {
    let milestoneDescs: [ResearchProjectMilestoneJsonModel]
}
