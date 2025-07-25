//
//  UpdateTrackerModel.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 7/25/25.
//

struct UpdateTrackerModel: CustomCodeable, Identifiable {
    let id: Int
    let announcements: Int
    let awards: Int
    let characters: Int
    let gear: Int
    let characterSkills: Int
    let contactRequests: Int
    let events: Int
    let eventAttendees: Int
    let preregs: Int
    let featureFlags: Int
    let intrigues: Int
    let players: Int
    let profileImages: Int
    let researchProjects: Int
    let skills: Int
    let skillCategories: Int
    let skillPrereqs: Int
    let xpReductions: Int
    let campStatus: Int
    let rulebookVersion: String
    let treatingWoundsVersion: String
    
}
