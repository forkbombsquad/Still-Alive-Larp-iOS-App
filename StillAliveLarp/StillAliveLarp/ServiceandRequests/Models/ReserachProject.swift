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
        let listModel: ResearchProjectMilestoneJsonListModel? = milestoneDescs.data(using: .utf8)?.toJsonObject()
        return listModel?.milestoneDescs ?? []
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
