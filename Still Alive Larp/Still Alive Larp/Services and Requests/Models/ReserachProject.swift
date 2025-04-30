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

}

struct ResearchProjectListModel: CustomCodeable {
    let researchProjects: [ResearchProjectModel]
}

struct ResearchProjectCreateModel: CustomCodeable {
    let name: String
    let description: String
    let milestones: Int
    let complete: String
}
