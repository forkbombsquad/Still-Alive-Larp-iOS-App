//
//  ServiceEndpoints.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/29/25.
//

class ServiceEndpoints {
    static let serviceMode: ServiceMode = .prod
    static let printServices = false
    // TODO make sure this is false before release

    private typealias urls = ServiceEndpoints.URL

    static func getUrl(_ endpoint: Endpoint) -> String {
        return "\(urls.base)\(urls.apiVersioning)\(endpoint.rawValue)"
    }

    enum ServiceMode {
        case prod, test
    }

    enum Endpoint: String {
        case playerSignIn = "players/sign_in/"
        case authToken = "auth/login"
        case playerCreate = "players/create"
        case announcementsAll = "announcements/all_ids/"
        case announcement = "announcements/"
        case announcementCreate = "announcements/create/"
        case charactersForPlayer = "characters/all_with_player_id/"
        case character = "characters/"
        case allCharacters = "characters/all/"
        case characterCreate = "characters/create/"
        case skill = "skills/"
        case allSkills = "skills/all/"
        case skillPrereqsForId = "skill-prereqs/all_with_skill_id/"
        case allSkillPrereqs = "skill-prereqs/all/"
        case allPlayers = "players/all/"
        case player = "players/"
        case awardPlayer = "admin/award_player/"
        case awardChar = "admin/award_character/"
        case awards = "award/all/"
        case takeSkill = "char-skill/create_with_player_id/"
        case getAllSkillsForChar = "char-skill/all_for_char/"
        case updateCharacter = "characters/update/"
        case updateBio = "characters/update_bio/"
        case allEvents = "event/all/"
        case createEvent = "event/create/"
        case eventUpdate = "event/update/"
        case checkInPlayer = "event-attendee/create/"
        case checkInCharacter = "event-attendee/check_in_character/"
        case giveCharCheckInRewards = "event-attendee/give_character_check_in_rewards/"
        case createContact = "contact/create/"
        case allContactRequests = "contact/all/"
        case updateContact = "contact/update/"
        case updateP = "players/update_p/"
        case updatePAdmin = "players/update_p_admin/"
        case getIntrigue = "intrigue/for_event/"
        case createIntrigue = "intrigue/create/"
        case updateIntrigue = "intrigue/update/"
        case getAllIntrigue = "intrigue/all/"
        case eventAttendeesForPlayer = "event-attendee/all_for_player/"
        case updatePlayer = "players/update/"
        case eventAttendeeUpdate = "event-attendee/update/"
        case giveXpReduction = "xp-red/take_class/"
        case getXpReductionsForChar = "xp-red/all_for_char/"
        case prereg = "prereg/create/"
        case updatePrereg = "prereg/update/"
        case allPreregsForEvent = "prereg/all_for_event/"
        case version = "app-version/"
        case deletePlayer = "players/delete/"
        case deleteCharacters = "characters/delete/"
        case deleteEventPreregs = "prereg/delete/"
        case deleteXpRedsForChar = "xp-red/delete/"
        case deleteAwards = "award/delete/"
        case deleteSkills = "char-skill/delete/"
        case deleteEventAttendee = "event-attendee/delete/"
        case allGear = "gear/all/"
        case allGearForChar = "gear/all_for_char/"
        case updateGear = "gear/update/"
        case createGear = "gear/create/"
        case deleteGear = "gear/delete/"
        case getFeatureFlag = "feature-flag/"
        case createFeatureFlag = "feature-flag/create/"
        case updateFeatureFlag = "feature-flag/update/"
        case deleteFeatureFlag = "feature-flag/delete/"
        case getAllFeatureFlags = "feature-flag/all/"
        case getProfileImage = "profile/player/"
        case createProfileImage = "profile/create/"
        case updateProfileImage = "profile/update/"
        case deleteProfileImage = "profile/delete/"
        case getResearchProject = "research-project/"
        case getAllResearchProjects = "research-project/all/"
        case updateResearchProject = "research-project/update/"
        case createResearchProject = "research-project/create/"

        var requestType: ServiceController.RequestType {
            switch self {
            case .playerSignIn, .announcementsAll, .announcement, .charactersForPlayer, .character, .skill, .allSkills, .skillPrereqsForId, .allSkillPrereqs, .allPlayers, .player, .awards, .allCharacters, .getAllSkillsForChar, .allEvents, .allContactRequests, .getIntrigue, .getAllIntrigue, .eventAttendeesForPlayer, .getXpReductionsForChar, .allPreregsForEvent, .version, .allGear, .allGearForChar, .getFeatureFlag, .getAllFeatureFlags, .getProfileImage, .getResearchProject, .getAllResearchProjects:
                    return .get
            case .authToken, .playerCreate, .characterCreate, .awardPlayer, .awardChar, .takeSkill, .announcementCreate, .createEvent, .checkInPlayer, .createContact, .createIntrigue, .giveXpReduction, .prereg, .createGear, .createFeatureFlag, .createProfileImage, .createResearchProject:
                    return .post
            case .updateCharacter, .eventUpdate, .checkInCharacter, .giveCharCheckInRewards, .updateBio, .updateContact, .updateP, .updatePAdmin, .updateIntrigue, .updatePlayer, .eventAttendeeUpdate, .updatePrereg, .updateGear, .updateFeatureFlag, .updateProfileImage, .updateResearchProject:
                    return .put
            case .deletePlayer, .deleteCharacters, .deleteEventPreregs, .deleteXpRedsForChar, .deleteAwards, .deleteSkills, .deleteEventAttendee, .deleteGear, .deleteFeatureFlag, .deleteProfileImage:
                    return .delete
            }
        }
    }

    struct URL {
        static var base: String {
            return ServiceEndpoints.serviceMode == .prod ? baseProd : baseTest
        }
        private static let baseProd = "https://stillalivelarp.com/"
        private static let baseTest = "stillalivetest/"
        static let apiVersioning = "api/v2/"
    }
}
