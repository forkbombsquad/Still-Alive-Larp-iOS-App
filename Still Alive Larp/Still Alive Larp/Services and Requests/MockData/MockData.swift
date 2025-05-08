//
//  MockData.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 12/23/22.
//

import Foundation

protocol MockData {
    static var oauthToken: OAuthTokenResponse { get }
    static var player: PlayerModel { get }
    static var playerList: PlayerListModel { get }
    static var announcementsList: AnnouncementsListModel { get }
    static var announcement: AnnouncementModel { get }
    static var characterListFullModel: CharacterListFullModel { get }
    static var characterList: CharacterListModel { get }
    static var character: CharacterModel { get }
    static var skill: SkillModel { get }
    static var skills: SkillListModel { get }
    static var prereqs: SkillPrereqListModel { get }
    static var awards: AwardListModel { get }
    static var characterSkill: CharacterSkillModel { get }
    static var characterSkillList: CharacterSkillListModel { get }
    static var event: EventModel { get }
    static var events: EventListModel { get }
    static var eventAttendee: EventAttendeeModel { get }
    static var eventAttendees: EventAttendeeListModel { get }
    static var contact: ContactRequestModel { get }
    static var contacts: ContactRequestListModel { get }
    static var intrigue: IntrigueModel { get }
    static var intrigues: IntrigueListModel { get }
    static var xpReduction: SpecialClassXpReductionModel { get }
    static var xpReductions: SpecialClassXpReductionListModel { get }
    static var prereg: EventPreregModel { get }
    static var preregs: EventPreregListModel { get }
    static var version: AppVersionModel { get }
    static var gear: GearModel { get }
    static var gearList: GearListModel { get }
    static var featureFlag: FeatureFlagModel { get }
    static var featureFlagList: FeatureFlagListModel { get }
    static var profileImageModel: ProfileImageModel { get }
    static var researchProject: ResearchProjectModel { get }
    static var researchProjects: ResearchProjectListModel { get }
    static var rulebook: Rulebook { get }
}

extension MockData {
    static func getResponse(_ request: MockRequest) -> Codable {
        switch request.endpoint {
            case .playerSignIn, .player, .playerCreate, .awardPlayer, .updateP, .updatePAdmin, .updatePlayer, .deletePlayer:
                return player
            case .authToken:
                return oauthToken
            case .announcementsAll:
                return announcementsList
            case .announcement:
                return announcement
            case .charactersForPlayer:
                return characterList
            case .characterCreate, .awardChar, .updateCharacter, .updateBio, .character, .giveCharCheckInRewards:
                return character
            case .skill:
                return skill
            case .allSkills:
                return skills
            case .skillPrereqsForId, .allSkillPrereqs:
                return prereqs
            case .allPlayers:
                return playerList
            case .awards, .deleteAwards:
                return awards
            case .allCharacters, .deleteCharacters:
                return characterListFullModel
            case .takeSkill:
                return characterSkill
            case .getAllSkillsForChar, .deleteSkills:
                return characterSkillList
            case .announcementCreate:
                return announcement
            case .allEvents:
                return events
            case .createEvent, .eventUpdate:
                return event
            case .checkInPlayer, .checkInCharacter, .eventAttendeeUpdate:
                return eventAttendee
            case .createContact, .updateContact:
                return contact
            case .allContactRequests:
                return contacts
            case .getIntrigue, .createIntrigue, .updateIntrigue:
                return intrigue
            case .getAllIntrigue:
                return intrigues
            case .eventAttendeesForPlayer, .deleteEventAttendee:
                return eventAttendees
            case .giveXpReduction:
                return xpReduction
            case .getXpReductionsForChar, .deleteXpRedsForChar:
                return xpReductions
            case .prereg, .updatePrereg:
                return prereg
            case .allPreregsForEvent, .deleteEventPreregs:
                return preregs
            case .version:
                return version
            case .allGear, .allGearForChar:
                return gearList
            case .createGear, .updateGear, .deleteGear:
                return gear
            case .getFeatureFlag, .createFeatureFlag, .updateFeatureFlag, .deleteFeatureFlag:
                return featureFlag
            case .getAllFeatureFlags:
                return featureFlagList
            case .getProfileImage, .createProfileImage, .updateProfileImage, .deleteProfileImage:
                return profileImageModel
        case .getResearchProject, .createResearchProject, .updateResearchProject:
                return researchProject
            case .getAllResearchProjects:
                return researchProjects
        }
    }
}

struct MockData1: MockData {
    
    static var featureFlag = FeatureFlagModel(id: 0, name: "oldskilltreeimage", description: "Old skill tree baybee. But this description goes beyond that for test data so we can see multilines work", activeAndroid: "FALSE", activeIos: "TRUE")

    static var featureFlagList = FeatureFlagListModel(results: [featureFlag])

    static var profileImageModel = ProfileImageModel(id: 0, playerId: 1, image: "TEST")


    static var oauthToken = OAuthTokenResponse(access_token: "TestAccessToken")

    static var player = PlayerModel(id: 1, username: "test@test.test", fullName: "Test Testerson", startDate: "2022/12/23", experience: "10", freeTier1Skills: "1", prestigePoints: "1", isCheckedIn: "FALSE", isCheckedInAsNpc: "FALSE", lastCheckIn: "", numEventsAttended: "2", numNpcEventsAttended: "0", isAdmin: "FALSE")

    static var announcementsList = AnnouncementsListModel(announcements: [AnnouncementSubModel(id: 1)])
    static var announcement = AnnouncementModel(id: 1, title: "Test Announcement", text: "This is a test announcment with mock data yo.", date: "2022/12/23")

    static var characterList = CharacterListModel(characters: [CharacterSubModel(id: 1, isAlive: "TRUE")])

    static var characterListFullModel = CharacterListFullModel(characters: [character])

    static var character = CharacterModel(id: 1, fullName: "John Doe", startDate: "2022/12/23", isAlive: "TRUE", deathDate: "", infection: "10", bio: "", approvedBio: "FALSE", bullets: "10", megas: "1", rivals: "5", rockets: "2", bulletCasings: "54", clothSupplies: "6", woodSupplies: "4", metalSupplies: "2", techSupplies: "8", medicalSupplies: "11", armor: CharacterModel.ArmorType.none.rawValue, unshakableResolveUses: "0", mysteriousStrangerUses: "0", playerId: 1, characterTypeId: Constants.CharacterTypes.standard)

    static var skill = SkillModel(id: 1, xpCost: "1", prestigeCost: "0", name: "Test Skill", description: "This is a desc", minInfection: "0", skillTypeId: 1, skillCategoryId: 1)

    static var skills = SkillListModel(results: [skill])

    static var prereqs = SkillPrereqListModel(skillPrereqs: [SkillPrereqModel(id: 1, baseSkillId: 1, prereqSkillId: 2)])

    static var playerList = PlayerListModel(players: [player])

    static var awards = AwardListModel(awards: [AwardModel(id: 1, playerId: 1, characterId: nil, awardType: "XP", reason: "Mock Reason", date: "2023/01/01", amount: "10")])

    static var characterSkill = CharacterSkillModel(id: 1, characterId: 1, skillId: 1, xpSpent: 0, fsSpent: 0, ppSpent: 0)

    static var characterSkillList = CharacterSkillListModel(charSkills: [characterSkill])

    static var event = EventModel(id: 1, title: "Example Event", description: "Descrption of Event", date: "2023/01/01", startTime: "4:00pm", endTime: "Midnight", isStarted: "FALSE", isFinished: "FALSE")

    static var events = EventListModel(events: [event])

    static var eventAttendee = EventAttendeeModel(id: 1, playerId: 1, characterId: nil, eventId: 1, isCheckedIn: "FALSE", asNpc: "FALSE")

    static var eventAttendees = EventAttendeeListModel(eventAttendees: [eventAttendee])

    static var contact = ContactRequestModel(id: 1, fullName: "John Doe", emailAddress: "test@test.test", postalCode: "54703", message: "This is a test contact message", read: "FALSE")

    static var contacts = ContactRequestListModel(contactRequests: [contact])

    static var intrigue = IntrigueModel(id: 1, eventId: 1, investigatorMessage: "Message for investigator", interrogatorMessage: "Message for interrogator", webOfInformantsMessage: "Message for web of informants")

    static var intrigues = IntrigueListModel(intrigues: [intrigue])

    static var xpReduction = SpecialClassXpReductionModel(id: 1, characterId: 1, skillId: 1, xpReduction: "1")

    static var xpReductions = SpecialClassXpReductionListModel(specialClassXpReductions: [xpReduction])

    static var prereg = EventPreregModel(id: 1, playerId: 1, characterId: 1, eventId: 1, regType: "NONE")

    static var preregs = EventPreregListModel(eventPreregs: [prereg])

    static var version = AppVersionModel(androidVersion: 1, iosVersion: 1, rulebookVersion: "2.0")

    static var gear = GearModel(id: 1, characterId: 1, gearJson: GearJsonListModel(gearJson: [GearJsonModel(name: "Hammerstrike", gearType: Constants.GearTypes.firearm, primarySubtype: Constants.GearPrimarySubtype.lightFirearm, secondarySubtype: Constants.GearSecondarySubtype.primaryFirearm, desc: "5 Shot Revolver")]).toJsonString()!)

    static var gearList = GearListModel(charGear: [gear])
    
    static var researchProject = ResearchProjectModel(id: 1, name: "Radio Tower Project", description: "Commander Davis's Radio Tower Project that the entire camp needs to pitch in for. It's big. It's bad. It's pretty neat. Spooky though.\n\nSome newline related stuff just cuz", milestones: 4, complete: "TRUE")
    
    static var researchProjects = ResearchProjectListModel(researchProjects: [researchProject])
    
    static var rulebook = Rulebook(version: "2.1.0", headings: [
        Heading(title: "Section 1", textsAndTables: [
            "This is a sentence that will appear before the first table. See the table below for more information:",
            Table(contents: [
                "Cost" : ["20 Bullets", "50 Bullets"],
                "Item" : ["Commander's Love", "New Ideas"]
            ]),
            "This sentence appears after the first table. Neat."
        ], subSubHeadings: [
            SubSubHeading("SubSubSection 1.0.1", textsAndTables: [
                "Generally this type of section will never happen. We try to keep Sub Sub headings within Sub Headings but it is techincally possible. See the table below for more info.",
                Table(contents: [
                    "Times this should happen" : ["0"],
                    "Times this might happen?" : ["1"],
                    "Is this table weirdly formatted?" : ["Yeah"],
                    "This column is extra long" : ["Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra Extra extra extra long. So so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so so much longer than you expected."]
                ])
            ])
        ], subHeadings: [
            SubHeading("Subsection 1.1", textsAndTables: [
                "This is a standard subsection. The majority of the rulebook is written into things like this.",
                "It's often done in multiple strings, like so.",
                "We might even have a relevant table with a lot of columns like the following color mixing chart:",
                Table(contents: [
                    "-" : ["<b>Red</b>", "<b>Yellow</b>", "<b>Blue</b>", "<b>All</b>", "<b>Red (additive)</b>", "<b>Green (additive)</b>", "<b>Blue (additive)</b>", "<b>All (additive)</b>"],
                    "Red" : ["Red", "Orange", "Purple", "Black", "-", "-", "-", "-"],
                    "Yellow" : ["Orange", "Yellow", "Green", "Black", "-", "-", "-", "-"],
                    "Blue" : ["Purple", "Green", "Blue", "Black", "-", "-", "-", "-"],
                    "All" : ["Black", "Black", "Black", "Black", "-", "-", "-", "-"],
                    "Red (additive)" : ["-", "-", "-", "-", "Red", "Yellow", "Magenta", "White"],
                    "Green (additive)" : ["-", "-", "-", "-", "Yellow", "Green", "Cyan", "White"],
                    "Blue (additive)" : ["-", "-", "-", "-", "Magenta", "Cyan", "Blue", "White"],
                    "All (additive)" : ["-", "-", "-", "-", "White", "White", "White", "White"]
                ]),
                "After a big table like that, you might need to specify a little extra information. Such as: this does not include sutractive colors for things like printer ink. See the section below for more info."
            ], subSubHeadings: [
                SubSubHeading("SubSubsection 1.1.1 - Printer/Paint Color", textsAndTables: [
                    "This is where you can see what alternate subtractive color mixing looks like.",
                    Table(contents: [
                        "-" : ["<b>Yellow</b>", "<b>Magenta</b>", "<b>Cyan</b>", "<b>All</b>"],
                        "Yellow" : ["Yellow", "Red", "Green", "Gray"],
                        "Magenta" : ["Red", "Magenta", "Blue", "Gray"],
                        "Cyan" : ["Green", "Blue", "Cyan", "Gray"],
                        "All" : ["Gray", "Gray", "Gray", "Gray"]
                    ])
                ]),
                SubSubHeading("SubSubsection 1.1.2", textsAndTables: [
                    "Colors are weird. Just though I'd put that in an extra section lol"
                ])
            ]),
            SubHeading("Subsection 1.2", textsAndTables: [
                "Here is another section with stuff"
            ], subSubHeadings: [
                SubSubHeading("SubSubsection 1.2.1", textsAndTables: [
                    "Here's some relevant information.",
                    "Here's some more on another line."
                ])
            ])
        ])
    ])

}
