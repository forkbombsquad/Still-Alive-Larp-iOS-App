//
//  UpdateTrackerModel.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 7/25/25.
//

struct UpdateTrackerModel: CustomCodeable, Identifiable {
    
    let id: Int
    private(set) var announcements: Int
    private(set) var awards: Int
    private(set) var characters: Int
    private(set) var gear: Int
    private(set) var characterSkills: Int
    private(set) var contactRequests: Int
    private(set) var events: Int
    private(set) var eventAttendees: Int
    private(set) var preregs: Int
    private(set) var featureFlags: Int
    private(set) var intrigues: Int
    private(set) var players: Int
    private(set) var profileImages: Int
    private(set) var researchProjects: Int
    private(set) var skills: Int
    private(set) var skillCategories: Int
    private(set) var skillPrereqs: Int
    private(set) var xpReductions: Int
    private(set) var campStatus: Int
    private(set) var rulebookVersion: String
    private(set) var treatingWoundsVersion: String
    
    static func empty() -> UpdateTrackerModel {
        UpdateTrackerModel(id: -1, announcements: -1, awards: -1, characters: -1, gear: -1, characterSkills: -1, contactRequests: -1, events: -1, eventAttendees: -1, preregs: -1, featureFlags: -1, intrigues: -1, players: -1, profileImages: -1, researchProjects: -1, skills: -1, skillCategories: -1, skillPrereqs: -1, xpReductions: -1, campStatus: -1, rulebookVersion: "", treatingWoundsVersion: "")
    }
    
    func getDifferences(_ other: UpdateTrackerModel) -> [DataManager.DataManagerType] {
        var updates: [DataManager.DataManagerType] = []
        if other.announcements != self.announcements {
            updates.append(.announcements)
        }
        if other.awards != self.awards {
            updates.append(.awards)
        }
        if other.characters != self.characters {
            updates.append(.characters)
        }
        if other.gear != self.gear {
            updates.append(.gear)
        }
        if other.characterSkills != self.characterSkills {
            updates.append(.characterSkills)
        }
        if other.contactRequests != self.contactRequests {
            updates.append(.contactRequests)
        }
        if other.events != self.events {
            updates.append(.events)
        }
        if other.eventAttendees != self.eventAttendees {
            updates.append(.eventAttendees)
        }
        if other.preregs != self.preregs {
            updates.append(.preregs)
        }
        if other.featureFlags != self.featureFlags {
            updates.append(.featureFlags)
        }
        if other.intrigues != self.intrigues {
            updates.append(.intrigues)
        }
        if other.players != self.players {
            updates.append(.players)
        }
        if other.profileImages != self.profileImages {
            updates.append(.profileImages)
        }
        if other.researchProjects != self.researchProjects {
            updates.append(.researchProjects)
        }
        if other.skills != self.skills {
            updates.append(.skills)
        }
        if other.skillCategories != self.skillCategories {
            updates.append(.skillCategories)
        }
        if other.skillPrereqs != self.skillPrereqs {
            updates.append(.skillPrereqs)
        }
        if other.xpReductions != self.xpReductions {
            updates.append(.xpReductions)
        }
        if other.campStatus != self.campStatus {
            updates.append(.campStatus)
        }
        if other.rulebookVersion != self.rulebookVersion {
            updates.append(.rulebook)
        }
        if other.treatingWoundsVersion != self.treatingWoundsVersion {
            updates.append(.treatingWounds)
        }
        return updates
    }
    
    mutating func updateInPlace(_ newTracker: UpdateTrackerModel, successfulUpdates: [DataManager.DataManagerType]) {
        for update in successfulUpdates {
            switch update {
            case .updateTracker:
                continue
            case .announcements:
                self.announcements = newTracker.announcements
            case .awards:
                self.awards = newTracker.awards
            case .characters:
                self.characters = newTracker.characters
            case .gear:
                self.gear = newTracker.gear
            case .characterSkills:
                self.characterSkills = newTracker.characterSkills
            case .contactRequests:
                self.contactRequests = newTracker.contactRequests
            case .events:
                self.events = newTracker.events
            case .eventAttendees:
                self.eventAttendees = newTracker.eventAttendees
            case .preregs:
                self.preregs = newTracker.preregs
            case .featureFlags:
                self.featureFlags = newTracker.featureFlags
            case .intrigues:
                self.intrigues = newTracker.intrigues
            case .players:
                self.players = newTracker.players
            case .profileImages:
                self.profileImages = newTracker.profileImages
            case .researchProjects:
                self.researchProjects = newTracker.researchProjects
            case .skills:
                self.skills = newTracker.skills
            case .skillCategories:
                self.skillCategories = newTracker.skillCategories
            case .skillPrereqs:
                self.skillPrereqs = newTracker.skillPrereqs
            case .xpReductions:
                self.xpReductions = newTracker.xpReductions
            case .rulebook:
                self.rulebookVersion = newTracker.rulebookVersion
            case .treatingWounds:
                self.treatingWoundsVersion = newTracker.treatingWoundsVersion
            case .campStatus:
                self.campStatus = newTracker.campStatus
            }
        }
    }
    
    func updateToNew(_ successfulUpdates: [DataManager.DataManagerType]) -> UpdateTrackerModel {
        var tracker = UpdateTrackerModel.empty()
        tracker.updateInPlace(self, successfulUpdates: successfulUpdates)
        return tracker
    }
    
}
