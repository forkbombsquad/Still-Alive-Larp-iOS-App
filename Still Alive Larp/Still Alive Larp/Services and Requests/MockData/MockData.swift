//
//  MockData.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 12/23/22.
//

import Foundation

struct MockDataManagement {
    static let allMockData: [MockData] = [MockData1()]
}

protocol MockData {
    var oauthToken: OAuthTokenResponse { get }
    var player: PlayerModel { get }
    var playerList: PlayerListModel { get }
    var announcementsList: AnnouncementsListModel { get }
    var announcement: AnnouncementModel { get }
    var characterListFullModel: CharacterListFullModel { get }
    var characterList: CharacterListModel { get }
    var character: CharacterModel { get }
    var skill: SkillModel { get }
    var skills: SkillListModel { get }
    var prereqs: SkillPrereqListModel { get }
    var awards: AwardListModel { get }
    var characterSkill: CharacterSkillModel { get }
    var characterSkillList: CharacterSkillListModel { get }
    var event: EventModel { get }
    var events: EventListModel { get }
    var eventAttendee: EventAttendeeModel { get }
    var eventAttendees: EventAttendeeListModel { get }
    var contact: ContactRequestModel { get }
    var contacts: ContactRequestListModel { get }
    var intrigue: IntrigueModel { get }
    var intrigues: IntrigueListModel { get }
    var xpReduction: SpecialClassXpReductionModel { get }
    var xpReductions: SpecialClassXpReductionListModel { get }
    var prereg: EventPreregModel { get }
    var preregs: EventPreregListModel { get }
    var version: AppVersionModel { get }
    var gear: GearModel { get }
    var gearList: GearListModel { get }
    var featureFlag: FeatureFlagModel { get }
    var featureFlagList: FeatureFlagListModel { get }
    var profileImageModel: ProfileImageModel { get }
    var researchProject: ResearchProjectModel { get }
    var researchProjects: ResearchProjectListModel { get }
    var rulebook: Rulebook { get }
    var playerCheckInBarcodeModel: PlayerCheckInBarcodeModel { get }
    var playerCheckOutBarcodeModel: PlayerCheckOutBarcodeModel { get }
}

extension MockData {
    
    func getResponse(_ request: MockRequest) -> Codable {
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

fileprivate struct MockData1: MockData {
    
    var featureFlag = FeatureFlagModel(id: 0, name: "oldskilltreeimage", description: "Old skill tree baybee. But this description goes beyond that for test data so we can see multilines work", activeAndroid: "FALSE", activeIos: "TRUE")

    var featureFlagList = FeatureFlagListModel(results: [
        FeatureFlagModel(id: 0, name: "oldskilltreeimage", description: "Old skill tree baybee. But this description goes beyond that for test data so we can see multilines work", activeAndroid: "FALSE", activeIos: "TRUE"),
        FeatureFlagModel(id: 1, name: "campStatus", description: "This is the camp status feature flag", activeAndroid: "FALSE", activeIos: "TRUE"),
        FeatureFlagModel(id: 2, name: "someotherflag", description: "This is some other flag", activeAndroid: "TRUE", activeIos: "TRUE"),
        FeatureFlagModel(id: 3, name: "afinalflag", description: "The fourth flag to test all states", activeAndroid: "FALSE", activeIos: "FALSE")
    ])

    var profileImageModel = ProfileImageModel(id: 0, playerId: 1, image: "TEST")

    var oauthToken = OAuthTokenResponse(access_token: "TestAccessToken")

    var player = PlayerModel(id: 1, username: "test@test.test", fullName: "Test Testerson", startDate: "2022/12/23", experience: "10", freeTier1Skills: "1", prestigePoints: "1", isCheckedIn: "FALSE", isCheckedInAsNpc: "FALSE", lastCheckIn: "", numEventsAttended: "2", numNpcEventsAttended: "0", isAdmin: "FALSE")

    var announcementsList = AnnouncementsListModel(announcements: [AnnouncementSubModel(id: 1)])
    var announcement = AnnouncementModel(id: 1, title: "Test Announcement", text: "This is a test announcment with mock data yo.", date: "2022/12/23")

    var characterList = CharacterListModel(characters: [CharacterSubModel(id: 1, isAlive: "TRUE")])

    var character = CharacterModel(id: 2, fullName: "Jane Dee", startDate: "2025/05/07", isAlive: "TRUE", deathDate: "", infection: "28", bio: "I have an appproved bio becuase I'm neat!", approvedBio: "TRUE", bullets: "20", megas: "12", rivals: "50", rockets: "23", bulletCasings: "0", clothSupplies: "1", woodSupplies: "2", metalSupplies: "0", techSupplies: "0", medicalSupplies: "14", armor: CharacterModel.ArmorType.metal.rawValue, unshakableResolveUses: "0", mysteriousStrangerUses: "0", playerId: 2, characterTypeId: Constants.CharacterTypes.standard)
    
    var characterListFullModel = CharacterListFullModel(characters: [
        CharacterModel(id: 1, fullName: "John Doe", startDate: "2022/12/23", isAlive: "TRUE", deathDate: "", infection: "10", bio: "", approvedBio: "FALSE", bullets: "10", megas: "1", rivals: "5", rockets: "2", bulletCasings: "54", clothSupplies: "6", woodSupplies: "4", metalSupplies: "2", techSupplies: "8", medicalSupplies: "11", armor: CharacterModel.ArmorType.none.rawValue, unshakableResolveUses: "0", mysteriousStrangerUses: "0", playerId: 1, characterTypeId: Constants.CharacterTypes.standard),
        CharacterModel(id: 2, fullName: "Jane Dee", startDate: "2025/05/07", isAlive: "TRUE", deathDate: "", infection: "28", bio: "I have an appproved bio becuase I'm neat!", approvedBio: "TRUE", bullets: "20", megas: "12", rivals: "50", rockets: "23", bulletCasings: "0", clothSupplies: "1", woodSupplies: "2", metalSupplies: "0", techSupplies: "0", medicalSupplies: "14", armor: CharacterModel.ArmorType.metal.rawValue, unshakableResolveUses: "0", mysteriousStrangerUses: "0", playerId: 2, characterTypeId: Constants.CharacterTypes.standard),
        CharacterModel(id: 3, fullName: "Dead Guy", startDate: "2025/05/07", isAlive: "FALSE", deathDate: "2025/04/04", infection: "78", bio: "I died :(", approvedBio: "TRUE", bullets: "1", megas: "2", rivals: "3", rockets: "4", bulletCasings: "5", clothSupplies: "6", woodSupplies: "7", metalSupplies: "8", techSupplies: "9", medicalSupplies: "10", armor: CharacterModel.ArmorType.bulletProof.rawValue, unshakableResolveUses: "0", mysteriousStrangerUses: "0", playerId: 3, characterTypeId: Constants.CharacterTypes.standard)
    ])

    var skill = SkillModel(id: 1, xpCost: "2", prestigeCost: "1", name: "Adaptable", description: "Your body adapts to the infection more easily than others. Your infection threshold for tier-2 'the infected' skills is lowered from 50% to 25%\n\n*This is a prestige skill It requires 1 prestige point in addition to its xp cost.", minInfection: "0", skillTypeId: 3, skillCategoryId: 14)

    var skills = SkillListModel(results: [
        SkillModel(id: 1, xpCost: "2", prestigeCost: "1", name: "Adaptable", description: "Your body adapts to the infection more easily than others. Your infection threshold for tier-2 'the infected' skills is lowered from 50% to 25%\n\n*This is a prestige skill It requires 1 prestige point in addition to its xp cost.", minInfection: "0", skillTypeId: 3, skillCategoryId: 14),
        SkillModel(id: 2, xpCost: "3", prestigeCost: "0", name: "Advanced Firearm Proficiency", description: "As Light Firearm Proficiency, but you can wield Advanced Firearms", minInfection: "0", skillTypeId: 1, skillCategoryId: 2),
        SkillModel(id: 20, xpCost: "3", prestigeCost: "0", name: "Expert: Profession", description: "From now on, all Profession type skills cost 1 less to take (minimum 1).\n\n*You may only take two specializatino type skills, one in tier 3 and one in tier 4", minInfection: "0", skillTypeId: 2, skillCategoryId: 15),
        SkillModel(id: 14, xpCost: "4", prestigeCost: "0", name: "Dead Man Sprinting", description: "As Dead Man Walking, but you may more more quickly, mimicing the movements and sounds of a Zoombie.", minInfection: "75", skillTypeId: 3, skillCategoryId: 13),
        SkillModel(id: 6, xpCost: "0", prestigeCost: "0", name: "Bash", description: "Allows you to Deconstruct Armor, Firearms, Gear and Melee Weapons. Also allows you to deal damage to Fortifications using a Melee Weapon, though doing so is loud and should be roleplayed as such.", minInfection: "0", skillTypeId: 1, skillCategoryId: 1)
    ])

    var prereqs = SkillPrereqListModel(skillPrereqs: [
        SkillPrereqModel(id: 1, baseSkillId: 2, prereqSkillId: 1),
        SkillPrereqModel(id: 1, baseSkillId: 14, prereqSkillId: 6)
    ])

    var playerList = PlayerListModel(players: [
        PlayerModel(id: 1, username: "test@test.test", fullName: "Test Testerson", startDate: "2022/12/23", experience: "10", freeTier1Skills: "1", prestigePoints: "1", isCheckedIn: "FALSE", isCheckedInAsNpc: "FALSE", lastCheckIn: "", numEventsAttended: "2", numNpcEventsAttended: "0", isAdmin: "FALSE"),
        PlayerModel(id: 2, username: "ope@ope.ope", fullName: "Jack O'Preacher", startDate: "2023/10/10", experience: "5", freeTier1Skills: "0", prestigePoints: "0", isCheckedIn: "TRUE", isCheckedInAsNpc: "FALSE", lastCheckIn: "2025/04/04", numEventsAttended: "3", numNpcEventsAttended: "1", isAdmin: "FALSE"),
        PlayerModel(id: 3, username: "cam@cam.cam", fullName: "Cam Cam", startDate: "2018/10/08", experience: "69", freeTier1Skills: "7", prestigePoints: "3", isCheckedIn: "TRUE", isCheckedInAsNpc: "FALSE", lastCheckIn: "2025/05/05", numEventsAttended: "2", numNpcEventsAttended: "0", isAdmin: "FALSE"),
        PlayerModel(id: 4, username: "admin@admin.admin", fullName: "Admin Boi", startDate: "2000/01/01", experience: "99", freeTier1Skills: "10", prestigePoints: "12", isCheckedIn: "TRUE", isCheckedInAsNpc: "TRUE", lastCheckIn: "2025/05/05", numEventsAttended: "8", numNpcEventsAttended: "7", isAdmin: "TRUE")
    ])

    var awards = AwardListModel(awards: [
        AwardModel(id: 1, playerId: 1, characterId: nil, awardType: AdminService.PlayerAwardType.xp.rawValue, reason: "Because", date: "2023/01/01", amount: "10"),
        AwardModel(id: 2, playerId: 2, characterId: nil, awardType: AdminService.PlayerAwardType.freeTier1Skills.rawValue, reason: "Because I wanted to", date: "2023/01/02", amount: "9"),
        AwardModel(id: 3, playerId: 4, characterId: nil, awardType: AdminService.PlayerAwardType.prestigePoints.rawValue, reason: "Winner winner chicken dinner", date: "2023/01/03", amount: "99"),
        AwardModel(id: 4, playerId: 1, characterId: 1, awardType: AdminService.CharAwardType.infection.rawValue, reason: "Bad offscreen bite", date: "2023/01/04", amount: "22"),
        AwardModel(id: 5, playerId: 2, characterId: 2, awardType: AdminService.CharAwardType.materialCasings.rawValue, reason: "Getting all the materials. 4 of each", date: "2023/01/05", amount: "4"),
        AwardModel(id: 6, playerId: 2, characterId: 2, awardType: AdminService.CharAwardType.materialWood.rawValue, reason: "Getting all the materials. 4 of each", date: "2023/01/05", amount: "4"),
        AwardModel(id: 7, playerId: 2, characterId: 2, awardType: AdminService.CharAwardType.materialCloth.rawValue, reason: "Getting all the materials. 4 of each", date: "2023/01/05", amount: "4"),
        AwardModel(id: 8, playerId: 2, characterId: 2, awardType: AdminService.CharAwardType.materialMetal.rawValue, reason: "Getting all the materials. 4 of each", date: "2023/01/05", amount: "4"),
        AwardModel(id: 9, playerId: 2, characterId: 2, awardType: AdminService.CharAwardType.materialTech.rawValue, reason: "Getting all the materials. 4 of each", date: "2023/01/05", amount: "4"),
        AwardModel(id: 10, playerId: 2, characterId: 2, awardType: AdminService.CharAwardType.materialMed.rawValue, reason: "Getting all the materials. 4 of each", date: "2023/01/05", amount: "4"),
        AwardModel(id: 11, playerId: 3, characterId: 3, awardType: AdminService.CharAwardType.ammoBullet.rawValue, reason: "Getting all the bullet types. 77 of each", date: "2023/01/06", amount: "77"),
        AwardModel(id: 12, playerId: 3, characterId: 3, awardType: AdminService.CharAwardType.ammoMega.rawValue, reason: "Getting all the bullet types. 77 of each", date: "2023/01/06", amount: "77"),
        AwardModel(id: 13, playerId: 3, characterId: 3, awardType: AdminService.CharAwardType.ammoRival.rawValue, reason: "Getting all the bullet types. 77 of each", date: "2023/01/06", amount: "77"),
        AwardModel(id: 14, playerId: 3, characterId: 3, awardType: AdminService.CharAwardType.ammoRocket.rawValue, reason: "Getting all the bullet types. 77 of each", date: "2023/01/06", amount: "77"),
    ])

    var characterSkill = CharacterSkillModel(id: 1, characterId: 1, skillId: 6, xpSpent: 0, fsSpent: 0, ppSpent: 0)

    var characterSkillList = CharacterSkillListModel(charSkills: [
        CharacterSkillModel(id: 1, characterId: 1, skillId: 6, xpSpent: 0, fsSpent: 0, ppSpent: 0),
        CharacterSkillModel(id: 2, characterId: 1, skillId: 1, xpSpent: 1, fsSpent: 0, ppSpent: 0),
        CharacterSkillModel(id: 3, characterId: 1, skillId: 2, xpSpent: 3, fsSpent: 0, ppSpent: 0),
        CharacterSkillModel(id: 4, characterId: 2, skillId: 6, xpSpent: 0, fsSpent: 0, ppSpent: 0),
        CharacterSkillModel(id: 5, characterId: 2, skillId: 20, xpSpent: 3, fsSpent: 0, ppSpent: 0),
        CharacterSkillModel(id: 6, characterId: 2, skillId: 14, xpSpent: 2, fsSpent: 0, ppSpent: 0),
        CharacterSkillModel(id: 7, characterId: 3, skillId: 6, xpSpent: 0, fsSpent: 0, ppSpent: 0)
        
    ])

    var event = EventModel(id: 1, title: "Example Event", description: "Descrption of Event", date: "2023/01/01", startTime: "4:00pm", endTime: "Midnight", isStarted: "FALSE", isFinished: "FALSE")

    var events = EventListModel(events: [
        EventModel(id: 1, title: "Finished Event", description: "This event was finished", date: "2023/01/01", startTime: "4:00pm", endTime: "Midnight", isStarted: "TRUE", isFinished: "TRUE"),
        EventModel(id: 2, title: "Active Event", description: "This event is active", date: "2023/01/02", startTime: "4:00pm", endTime: "Midnight", isStarted: "TRUE", isFinished: "FALSE"),
        EventModel(id: 3, title: "Unstarted Event", description: "This event has not started yet", date: "2023/01/03", startTime: "4:00pm", endTime: "Midnight", isStarted: "FALSE", isFinished: "FALSE"),
    ])

    var eventAttendee = EventAttendeeModel(id: 1, playerId: 1, characterId: nil, eventId: 1, isCheckedIn: "FALSE", asNpc: "FALSE")

    var eventAttendees = EventAttendeeListModel(eventAttendees: [
        EventAttendeeModel(id: 1, playerId: 1, characterId: nil, eventId: 1, isCheckedIn: "FALSE", asNpc: "FALSE"),
        EventAttendeeModel(id: 2, playerId: 2, characterId: 2, eventId: 1, isCheckedIn: "FALSE", asNpc: "FALSE"),
        EventAttendeeModel(id: 3, playerId: 3, characterId: 3, eventId: 1, isCheckedIn: "FALSE", asNpc: "FALSE"),
        EventAttendeeModel(id: 4, playerId: 4, characterId: 4, eventId: 1, isCheckedIn: "FALSE", asNpc: "FALSE"),
        EventAttendeeModel(id: 5, playerId: 2, characterId: 2, eventId: 2, isCheckedIn: "TRUE", asNpc: "FALSE"),
        EventAttendeeModel(id: 6, playerId: 3, characterId: 3, eventId: 2, isCheckedIn: "TRUE", asNpc: "FALSE"),
        EventAttendeeModel(id: 7, playerId: 4, characterId: 4, eventId: 2, isCheckedIn: "TRUE", asNpc: "TRUE")
    ])

    var contact = ContactRequestModel(id: 1, fullName: "John Doe", emailAddress: "test@test.test", postalCode: "54703", message: "This is a test contact message", read: "FALSE")

    var contacts = ContactRequestListModel(contactRequests: [
        ContactRequestModel(id: 1, fullName: "John Doe", emailAddress: "test@test.test", postalCode: "54703", message: "This is a test contact message", read: "FALSE"),
        ContactRequestModel(id: 2, fullName: "Jane Dee", emailAddress: "jane@jane.jane", postalCode: "53959", message: "Please let me play still alive!", read: "TRUE")
    ])

    var intrigue = IntrigueModel(id: 1, eventId: 1, investigatorMessage: "Message for investigator", interrogatorMessage: "Message for interrogator", webOfInformantsMessage: "Message for web of informants")

    var intrigues = IntrigueListModel(intrigues: [
        IntrigueModel(id: 1, eventId: 1, investigatorMessage: "You will find something cool", interrogatorMessage: "You'll probably need a scavenger", webOfInformantsMessage: "This isn't used"),
        IntrigueModel(id: 2, eventId: 2, investigatorMessage: "Make sure you have Bash ready!", interrogatorMessage: "Gushers be afoot!", webOfInformantsMessage: "This isn't used"),
        IntrigueModel(id: 3, eventId: 3, investigatorMessage: "The Juggernaut is coming", interrogatorMessage: "Beware!", webOfInformantsMessage: "This isn't used")
    ])

    var xpReduction = SpecialClassXpReductionModel(id: 1, characterId: 1, skillId: 1, xpReduction: "1")

    var xpReductions = SpecialClassXpReductionListModel(specialClassXpReductions: [
        SpecialClassXpReductionModel(id: 1, characterId: 1, skillId: 1, xpReduction: "1"),
        SpecialClassXpReductionModel(id: 2, characterId: 2, skillId: 1, xpReduction: "1"),
        SpecialClassXpReductionModel(id: 3, characterId: 2, skillId: 14, xpReduction: "2")
    ])

    var prereg = EventPreregModel(id: 1, playerId: 1, characterId: 1, eventId: 1, regType: "NONE")

    var preregs = EventPreregListModel(eventPreregs: [
        EventPreregModel(id: 1, playerId: 1, characterId: nil, eventId: 1, regType: EventRegType.notPrereged.rawValue),
        EventPreregModel(id: 2, playerId: 2, characterId: 2, eventId: 1, regType: EventRegType.free.rawValue),
        EventPreregModel(id: 3, playerId: 3, characterId: 3, eventId: 1, regType: EventRegType.basic.rawValue),
        EventPreregModel(id: 4, playerId: 4, characterId: 4, eventId: 1, regType: EventRegType.premium.rawValue),
        EventPreregModel(id: 5, playerId: 2, characterId: nil, eventId: 2, regType: EventRegType.basic.rawValue),
        EventPreregModel(id: 6, playerId: 3, characterId: nil, eventId: 2, regType: EventRegType.premium.rawValue),
        EventPreregModel(id: 7, playerId: 4, characterId: 4, eventId: 2, regType: EventRegType.premium.rawValue),
        EventPreregModel(id: 8, playerId: 1, characterId: nil, eventId: 3, regType: EventRegType.premium.rawValue),
        EventPreregModel(id: 9, playerId: 2, characterId: 3, eventId: 3, regType: EventRegType.premium.rawValue),
        EventPreregModel(id: 10, playerId: 4, characterId: nil, eventId: 3, regType: EventRegType.basic.rawValue)
    ])

    var version = AppVersionModel(androidVersion: 1, iosVersion: 1, rulebookVersion: "2.0")

    var gear = GearModel(id: 1, characterId: 1, gearJson: GearJsonListModel(gearJson: [GearJsonModel(name: "Hammerstrike", gearType: Constants.GearTypes.firearm, primarySubtype: Constants.GearPrimarySubtype.lightFirearm, secondarySubtype: Constants.GearSecondarySubtype.primaryFirearm, desc: "5 Shot Revolver")]).toJsonString()!)

    var gearList = GearListModel(charGear: [
        GearModel(id: 1, characterId: 1, gearJson: GearJsonListModel(gearJson: [GearJsonModel(name: "Hammerstrike", gearType: Constants.GearTypes.firearm, primarySubtype: Constants.GearPrimarySubtype.lightFirearm, secondarySubtype: Constants.GearSecondarySubtype.primaryFirearm, desc: "5 Shot Revolver")]).toJsonString()!),
        GearModel(id: 2, characterId: 2, gearJson: GearJsonListModel(gearJson: [GearJsonModel(name: "Fireaxe", gearType: Constants.GearTypes.meleeWeapon, primarySubtype: Constants.GearPrimarySubtype.heavyMeleeWeapon, secondarySubtype: Constants.GearSecondarySubtype.none, desc: "Big fireaxe")]).toJsonString()!),
        GearModel(id: 3, characterId: 3, gearJson: GearJsonListModel(gearJson: [
            GearJsonModel(name: "Rhino", gearType: Constants.GearTypes.firearm, primarySubtype: Constants.GearPrimarySubtype.advancedFirearm, secondarySubtype: Constants.GearSecondarySubtype.none, desc: "Big ol boi"),
            GearJsonModel(name: "My Cool Bag", gearType: Constants.GearTypes.bag, primarySubtype: Constants.GearPrimarySubtype.largeBag, secondarySubtype: Constants.GearSecondarySubtype.none, desc: "A big ol bag")
        ]).toJsonString()!)
    ])
    
    var researchProject = ResearchProjectModel(id: 1, name: "Radio Tower Project", description: "Commander Davis's Radio Tower Project that the entire camp needs to pitch in for. It's big. It's bad. It's pretty neat. Spooky though.\n\nSome newline related stuff just cuz", milestones: 4, complete: "TRUE")
    
    var researchProjects = ResearchProjectListModel(researchProjects: [
        ResearchProjectModel(id: 1, name: "Radio Tower Project", description: "Commander Davis's Radio Tower Project that the entire camp needs to pitch in for. It's big. It's bad. It's pretty neat. Spooky though.\n\nSome newline related stuff just cuz", milestones: 4, complete: "TRUE"),
        ResearchProjectModel(id: 2, name: "Curing the Infection", description: "This probably won't happen. No one is even working on it.", milestones: 0, complete: "FALSE")
    ])
    
    var rulebook = Rulebook(version: "2.1.0", headings: [
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
    
    var playerCheckInBarcodeModel = PlayerCheckInBarcodeModel(player: PlayerBarcodeModel(PlayerModel(id: 1, username: "test@test.test", fullName: "Test Testerson", startDate: "2022/12/23", experience: "10", freeTier1Skills: "1", prestigePoints: "1", isCheckedIn: "FALSE", isCheckedInAsNpc: "FALSE", lastCheckIn: "", numEventsAttended: "2", numNpcEventsAttended: "0", isAdmin: "FALSE")), character: CharacterBarcodeModel(FullCharacterModel(CharacterModel(id: 2, fullName: "Jane Dee", startDate: "2025/05/07", isAlive: "TRUE", deathDate: "", infection: "28", bio: "I have an appproved bio becuase I'm neat!", approvedBio: "TRUE", bullets: "20", megas: "12", rivals: "50", rockets: "23", bulletCasings: "0", clothSupplies: "1", woodSupplies: "2", metalSupplies: "0", techSupplies: "0", medicalSupplies: "14", armor: CharacterModel.ArmorType.metal.rawValue, unshakableResolveUses: "0", mysteriousStrangerUses: "0", playerId: 2, characterTypeId: Constants.CharacterTypes.standard))), event: EventBarcodeModel(EventModel(id: 1, title: "Example Event", description: "Descrption of Event", date: "2023/01/01", startTime: "4:00pm", endTime: "Midnight", isStarted: "FALSE", isFinished: "FALSE")), relevantSkills: [])
    
    var playerCheckOutBarcodeModel = PlayerCheckOutBarcodeModel(player: PlayerBarcodeModel(PlayerModel(id: 1, username: "test@test.test", fullName: "Test Testerson", startDate: "2022/12/23", experience: "10", freeTier1Skills: "1", prestigePoints: "1", isCheckedIn: "FALSE", isCheckedInAsNpc: "FALSE", lastCheckIn: "", numEventsAttended: "2", numNpcEventsAttended: "0", isAdmin: "FALSE")), character: CharacterBarcodeModel(FullCharacterModel(CharacterModel(id: 2, fullName: "Jane Dee", startDate: "2025/05/07", isAlive: "TRUE", deathDate: "", infection: "28", bio: "I have an appproved bio becuase I'm neat!", approvedBio: "TRUE", bullets: "20", megas: "12", rivals: "50", rockets: "23", bulletCasings: "0", clothSupplies: "1", woodSupplies: "2", metalSupplies: "0", techSupplies: "0", medicalSupplies: "14", armor: CharacterModel.ArmorType.metal.rawValue, unshakableResolveUses: "0", mysteriousStrangerUses: "0", playerId: 2, characterTypeId: Constants.CharacterTypes.standard))), eventAttendeeId: 1, eventId: 1, relevantSkills: [])

}
