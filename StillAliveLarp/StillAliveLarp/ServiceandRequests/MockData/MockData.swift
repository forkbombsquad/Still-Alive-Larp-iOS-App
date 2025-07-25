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
    var playerList: PlayerListModel { get }
    var announcementsList: AnnouncementsListModel { get }
    var announcement: AnnouncementModel { get }
    var characterListFullModel: CharacterListFullModel { get }
    var skills: SkillListModel { get }
    var prereqs: SkillPrereqListModel { get }
    var awards: AwardListModel { get }
    var characterSkillList: CharacterSkillListModel { get }
    var events: EventListModel { get }
    var eventAttendees: EventAttendeeListModel { get }
    var contacts: ContactRequestListModel { get }
    var intrigues: IntrigueListModel { get }
    var xpReductions: SpecialClassXpReductionListModel { get }
    var preregs: EventPreregListModel { get }
    var version: AppVersionModel { get }
    var gearList: GearListModel { get }
    var featureFlagList: FeatureFlagListModel { get }
    var profileImageModel: ProfileImageModel { get }
    var researchProjects: ResearchProjectListModel { get }
    var rulebook: Rulebook { get }
    var skillCategories: SKillCategoryListModel { get }
    var updateTracker: UpdateTrackerModel { get }
}

extension MockData {
    
    func player(_ index: Int = 0) -> PlayerModel {
        return playerList.players[index]
    }
    
    func player(id: Int) -> PlayerModel {
        return playerList.players.first(where: { $0.id == id } )!
    }
    
    func characterList() -> [CharacterSubModel] {
        return characterListFullModel.characters.map { $0.subModel }
    }
    
    func character(_ index: Int = 0) -> CharacterModel {
        return characterListFullModel.characters[index]
    }
    
    func character(id: Int) -> CharacterModel {
        return characterListFullModel.characters.first(where: { $0.id == id } )!
    }
    
    func character(playerId: Int) -> CharacterModel {
        return characterListFullModel.characters.first(where: { $0.playerId == playerId } )!
    }
    
    func fullCharacters() -> [FullCharacterModel] {
        var fcs = [FullCharacterModel]()
        let fs = fullSkills()
        for character in characterListFullModel.characters {
            var fc = FullCharacterModel(character)
            let csl = characterSkillList.charSkills
            for charSkill in csl.filter({ $0.characterId == character.id }) {
                guard let skill = fs.first(where: { $0.id == charSkill.skillId }) else { continue }
                fc.skills.append(skill)
            }
            fcs.append(fc)
        }
        return fcs
    }
    
    func skill(_ index: Int = 0) -> SkillModel {
        return skills.results[index]
    }
    
    func skill(id: Int) -> SkillModel {
        return skills.results.first(where: { $0.id == id} )!
    }
    
    func fullSkills() -> [FullSkillModel] {
        var fs = [FullSkillModel]()
        for skill in skills.results {
            fs.append(FullSkillModel(skill))
        }
        for (index, skill) in fs.enumerated() {
            for prereq in prereqs.skillPrereqs.filter({ $0.baseSkillId == skill.id }) {
                guard let pskill = fs.first(where: { $0.id == prereq.prereqSkillId }) else { continue }
                fs[index].prereqs.append(pskill)
            }
        }
        return fs
    }
    
    func characterSkill(_ index: Int = 0) -> CharacterSkillModel {
        return characterSkillList.charSkills[index]
    }
    
    func characterSkill(id: Int) -> CharacterSkillModel {
        return characterSkillList.charSkills.first(where: { $0.id == id} )!
    }
    
    func characterSkill(skillId: Int, characterId: Int) -> CharacterSkillModel {
        return characterSkillList.charSkills.first(where: { $0.skillId == skillId && $0.characterId == characterId } )!
    }
    
    func event(_ index: Int = 0) -> EventModel {
        return events.events[index]
    }
    
    func event(id: Int) -> EventModel {
        return events.events.first(where: { $0.id == id })!
    }
    
    func eventAttendee(_ index: Int = 0) -> EventAttendeeModel {
        return eventAttendees.eventAttendees[index]
    }
    
    func eventAttendee(id: Int) -> EventAttendeeModel {
        return eventAttendees.eventAttendees.first(where: { $0.id == id })!
    }
    
    func eventAttendee(playerId: Int, characterId: Int? = nil, eventId: Int) -> EventAttendeeModel {
        return eventAttendees.eventAttendees.first(where: { $0.playerId == playerId && $0.characterId == characterId && $0.eventId == eventId })!
    }
    
    func contact(_ index: Int = 0) -> ContactRequestModel {
        return contacts.contactRequests[index]
    }
    
    func contact(id: Int) -> ContactRequestModel {
        return contacts.contactRequests.first(where: { $0.id == id })!
    }
    
    func intrigue(_ index: Int = 0) -> IntrigueModel {
        return intrigues.intrigues[index]
    }
    
    func intrigue(id: Int) -> IntrigueModel {
        return intrigues.intrigues.first(where: { $0.id == id })!
    }
    
    func xpReduction(_ index: Int = 0) -> SpecialClassXpReductionModel {
        return xpReductions.specialClassXpReductions[index]
    }
    
    func xpReduction(id: Int) -> SpecialClassXpReductionModel {
        return xpReductions.specialClassXpReductions.first(where: { $0.id == id })!
    }
    
    func xpReduction(characterId: Int, skillId: Int) -> SpecialClassXpReductionModel {
        return xpReductions.specialClassXpReductions.first(where: { $0.characterId == characterId && $0.skillId == skillId })!
    }
    
    func prereg(_ index: Int = 0) -> EventPreregModel {
        return preregs.eventPreregs[index]
    }
    
    func prereg(id: Int) -> EventPreregModel {
        return preregs.eventPreregs.first(where: { $0.id == id })!
    }
    
    func prereg(eventId: Int, playerId: Int) -> EventPreregModel {
        return preregs.eventPreregs.first(where: { $0.eventId == eventId && $0.playerId == playerId })!
    }
    
    func gear(_ index: Int = 0) -> GearModel {
        return gearList.charGear[index]
    }
    
    func gear(id: Int) -> GearModel {
        return gearList.charGear.first(where: { $0.id == id })!
    }
    
    func gear(characterId: Int) -> GearModel {
        return gearList.charGear.first(where: { $0.characterId == characterId })!
    }
    
    func featureFlag(_ index: Int = 0) -> FeatureFlagModel {
        return featureFlagList.results[index]
    }
    
    func featureFlag(id: Int) -> FeatureFlagModel {
        return featureFlagList.results.first(where: { $0.id == id })!
    }
    
    func researchProject(_ index: Int = 0) -> ResearchProjectModel {
        return researchProjects.researchProjects[index]
    }
    
    func researchProject(id: Int) -> ResearchProjectModel {
        return researchProjects.researchProjects.first(where: { $0.id == id })!
    }
    
    func skillCategory(_ index: Int = 0) -> SkillCategoryModel {
        return skillCategories.results[index]
    }
    
    func researchProject(id: Int) -> SkillCategoryModel {
        return skillCategories.results.first(where: { $0.id == id })!
    }
    
    func playerCheckInBarcodeModel(playerId: Int = 1, characterId: Int? = nil, eventId: Int = 1) -> PlayerCheckInBarcodeModel {
        let player = playerList.players.first(where: { $0.id == playerId })!
        let char = fullCharacters().first(where: { $0.id == (characterId ?? -1) })
        let event = events.events.first(where: { $0.id == eventId })!
        let gear = gearList.charGear.first(where: { $0.characterId == characterId })
        
        return PlayerCheckInBarcodeModel(player: player.barcodeModel, character: char?.barcodeModel, event: event.barcodeModel, relevantSkills: char?.getRelevantBarcodeSkills() ?? [], gear: gear)
    }
    
    func playerCheckOutBarcodeModel(playerId: Int = 1, characterId: Int? = nil, eventAttendeeId: Int = 1, eventId: Int = 1) -> PlayerCheckOutBarcodeModel {
        let player = playerList.players.first(where: { $0.id == playerId })!
        let char = fullCharacters().first(where: { $0.id == (characterId ?? -1) })
        return PlayerCheckOutBarcodeModel(player: player.barcodeModel, character: char?.barcodeModel, eventAttendeeId: eventAttendeeId, eventId: eventId, relevantSkills: char?.getRelevantBarcodeSkills() ?? [])
    }
    
    func getResponse(_ request: MockRequest) -> Codable {
        switch request.endpoint {
            case .playerSignIn, .player, .playerCreate, .awardPlayer, .updateP, .updatePAdmin, .updatePlayer, .deletePlayer:
                return player()
            case .authToken:
                return oauthToken
            case .announcementsAll:
                return announcementsList
            case .announcement:
                return announcement
            case .charactersForPlayer:
                return characterList()
            case .characterCreate, .awardChar, .updateCharacter, .updateBio, .character, .giveCharCheckInRewards, .createPlannedCharacter:
                return character()
            case .skill:
                return skill()
            case .allSkills:
                return skills
            case .skillPrereqsForId, .allSkillPrereqs:
                return prereqs
            case .allPlayers:
                return playerList
            case .awards, .deleteAwards:
                return awards
            case .allCharacters, .deleteCharacters, .charactersForPlayerWithType, .allCharactersWithType, .allNPCCharacters:
                return characterListFullModel
            case .takeSkill, .createPlannedCharacterSkill:
                return characterSkill()
            case .getAllSkillsForChar, .deleteSkills:
                return characterSkillList
            case .announcementCreate:
                return announcement
            case .allEvents:
                return events
            case .createEvent, .eventUpdate:
                return event()
            case .checkInPlayer, .checkInCharacter, .eventAttendeeUpdate:
                return eventAttendee()
            case .createContact, .updateContact:
                return contact()
            case .allContactRequests:
                return contacts
            case .getIntrigue, .createIntrigue, .updateIntrigue:
                return intrigue()
            case .getAllIntrigue:
                return intrigues
            case .eventAttendeesForPlayer, .deleteEventAttendee, .getAttendeesForEvent:
                return eventAttendees
            case .giveXpReduction:
                return xpReduction()
            case .getXpReductionsForChar, .deleteXpRedsForChar:
                return xpReductions
            case .prereg, .updatePrereg:
                return prereg()
            case .allPreregsForEvent, .deleteEventPreregs:
                return preregs
            case .version:
                return version
            case .allGear, .allGearForChar:
                return gearList
            case .createGear, .updateGear, .deleteGear:
                return gear()
            case .getFeatureFlag, .createFeatureFlag, .updateFeatureFlag, .deleteFeatureFlag:
                return featureFlag()
            case .getAllFeatureFlags:
                return featureFlagList
            case .getProfileImage, .createProfileImage, .updateProfileImage, .deleteProfileImage:
                return profileImageModel
            case .getResearchProject, .createResearchProject, .updateResearchProject:
                return researchProject()
            case .getAllResearchProjects:
                return researchProjects
            case .getAllSkillCategories:
                return skillCategories
            case .updateTracker:
                return updateTracker
        }
    }
    
}

fileprivate struct MockData1: MockData {
    
    var featureFlagList = FeatureFlagListModel(results: [
        FeatureFlagModel(id: 0, name: "oldskilltreeimage", description: "Old skill tree baybee. But this description goes beyond that for test data so we can see multilines work", activeAndroid: "FALSE", activeIos: "TRUE"),
        FeatureFlagModel(id: 1, name: "campStatus", description: "This is the camp status feature flag", activeAndroid: "FALSE", activeIos: "FALSE"),
        FeatureFlagModel(id: 2, name: "someotherflag", description: "This is some other flag", activeAndroid: "TRUE", activeIos: "TRUE"),
        FeatureFlagModel(id: 3, name: "afinalflag", description: "The fourth flag to test all states", activeAndroid: "FALSE", activeIos: "TRUE")
    ])

    var profileImageModel = ProfileImageModel(id: 0, playerId: 1, image: "TEST")

    var oauthToken = OAuthTokenResponse(access_token: "TestAccessToken")

    var announcementsList = AnnouncementsListModel(announcements: [AnnouncementSubModel(id: 1)])
    var announcement = AnnouncementModel(id: 1, title: "Test Announcement", text: "This is a test announcment with mock data yo.", date: "2022/12/23")
    
    var characterListFullModel = CharacterListFullModel(characters: [
        CharacterModel(id: 1, fullName: "John Doe", startDate: "2022/12/23", isAlive: "TRUE", deathDate: "", infection: "10", bio: "", approvedBio: "FALSE", bullets: "10", megas: "1", rivals: "5", rockets: "2", bulletCasings: "54", clothSupplies: "6", woodSupplies: "4", metalSupplies: "2", techSupplies: "8", medicalSupplies: "11", armor: CharacterModel.ArmorType.none.rawValue, unshakableResolveUses: "0", mysteriousStrangerUses: "0", playerId: 1, characterTypeId: Constants.CharacterTypes.standard),
        CharacterModel(id: 2, fullName: "Jane Dee", startDate: "2025/05/07", isAlive: "TRUE", deathDate: "", infection: "28", bio: "I have an appproved bio becuase I'm neat!", approvedBio: "TRUE", bullets: "20", megas: "12", rivals: "50", rockets: "23", bulletCasings: "0", clothSupplies: "1", woodSupplies: "2", metalSupplies: "0", techSupplies: "0", medicalSupplies: "14", armor: CharacterModel.ArmorType.metal.rawValue, unshakableResolveUses: "0", mysteriousStrangerUses: "0", playerId: 2, characterTypeId: Constants.CharacterTypes.standard),
        CharacterModel(id: 3, fullName: "Just Some Guy", startDate: "2025/05/08", isAlive: "TRUE", deathDate: "", infection: "69", bio: "I'm not dead yet. My bio isn't approved yet though :(", approvedBio: "FALSE", bullets: "5", megas: "3", rivals: "6", rockets: "8", bulletCasings: "2", clothSupplies: "4", woodSupplies: "8", metalSupplies: "0", techSupplies: "2", medicalSupplies: "0", armor: CharacterModel.ArmorType.bulletProof.rawValue, unshakableResolveUses: "0", mysteriousStrangerUses: "0", playerId: 3, characterTypeId: Constants.CharacterTypes.standard),
        CharacterModel(id: 4, fullName: "Dead Guy", startDate: "2025/05/07", isAlive: "FALSE", deathDate: "2025/04/04", infection: "78", bio: "I died :(", approvedBio: "TRUE", bullets: "1", megas: "2", rivals: "3", rockets: "4", bulletCasings: "5", clothSupplies: "6", woodSupplies: "7", metalSupplies: "8", techSupplies: "9", medicalSupplies: "10", armor: CharacterModel.ArmorType.bulletProof.rawValue, unshakableResolveUses: "0", mysteriousStrangerUses: "0", playerId: 4, characterTypeId: Constants.CharacterTypes.standard)
    ])
    
    var skills = SkillListModel(results: [
        SkillModel(id: 6, xpCost: "0", prestigeCost: "0", name: "Bash", description: "Break Stuff", minInfection: "0", skillTypeId: 1, skillCategoryId: 1),
        SkillModel(id: 25, xpCost: "0", prestigeCost: "0", name: "Follow the Leader", description: "Do tasks you aren't trained for", minInfection: "0", skillTypeId: 3, skillCategoryId: 1),
        SkillModel(id: 41, xpCost: "0", prestigeCost: "0", name: "Light Firearm Proficiency", description: "Light Firearm Wielding", minInfection: "0", skillTypeId: 1, skillCategoryId: 1),
        SkillModel(id: 72, xpCost: "0", prestigeCost: "0", name: "Super Light Melee Weapon Proficiency", description: "Super Light Melee Weapon Wielding", minInfection: "0", skillTypeId: 1, skillCategoryId: 1),
        SkillModel(id: 76, xpCost: "0", prestigeCost: "0", name: "Tap", description: "Tap them zomboids", minInfection: "0", skillTypeId: 1, skillCategoryId: 1),
        SkillModel(id: 108, xpCost: "0", prestigeCost: "0", name: "Weapon Finesse", description: "Wield smol boiz", minInfection: "0", skillTypeId: 1, skillCategoryId: 1),
        SkillModel(id: 1, xpCost: "2", prestigeCost: "1", name: "Adaptable", description: "Tier 3 infection at 25%", minInfection: "0", skillTypeId: 3, skillCategoryId: 14),
        SkillModel(id: 23, xpCost: "4", prestigeCost: "1", name: "Extremely Adaptable", description: "Tier 5 infection at 50%", minInfection: "0", skillTypeId: 3, skillCategoryId: 14),
        SkillModel(id: 5, xpCost: "4", prestigeCost: "0", name: "Bandoliers", description: "+2 event bullets", minInfection: "0", skillTypeId: 3, skillCategoryId: 8),
        SkillModel(id: 15, xpCost: "1", prestigeCost: "0", name: "Deep Pockets", description: "+2 event bullets", minInfection: "0", skillTypeId: 3, skillCategoryId: 8),
        SkillModel(id: 16, xpCost: "2", prestigeCost: "0", name: "Deeper Pockets", description: "+2 event bullets", minInfection: "0", skillTypeId: 3, skillCategoryId: 8),
        SkillModel(id: 61, xpCost: "3", prestigeCost: "0", name: "Parachute Pants", description: "+2 event bullets", minInfection: "0", skillTypeId: 3, skillCategoryId: 8),
        SkillModel(id: 37, xpCost: "2", prestigeCost: "0", name: "Interrogator", description: "+1 true fact", minInfection: "0", skillTypeId: 2, skillCategoryId: 10),
        SkillModel(id: 38, xpCost: "1", prestigeCost: "0", name: "Investigator", description: "1 true fact", minInfection: "0", skillTypeId: 2, skillCategoryId: 10),
        SkillModel(id: 55, xpCost: "4", prestigeCost: "0", name: "Natural Armor", description: "+1 blue beads", minInfection: "0", skillTypeId: 3, skillCategoryId: 7),
        SkillModel(id: 60, xpCost: "2", prestigeCost: "0", name: "Pain Tolerance", description: "+1 blue beads", minInfection: "0", skillTypeId: 3, skillCategoryId: 7),
        SkillModel(id: 70, xpCost: "2", prestigeCost: "0", name: "Scaled Skin", description: "+1 red beads", minInfection: "50", skillTypeId: 3, skillCategoryId: 13),
        SkillModel(id: 80, xpCost: "1", prestigeCost: "0", name: "Tough Skin", description: "+1 blue beads", minInfection: "0", skillTypeId: 3, skillCategoryId: 7),
        SkillModel(id: 96, xpCost: "2", prestigeCost: "1", name: "Plot Armor", description: "+1 black beads", minInfection: "0", skillTypeId: 3, skillCategoryId: 14),
        SkillModel(id: 13, xpCost: "2", prestigeCost: "0", name: "Dead Man Walking", description: "Pretend to be a zombie.", minInfection: "50", skillTypeId: 3, skillCategoryId: 13),
        SkillModel(id: 14, xpCost: "4", prestigeCost: "0", name: "Dead Man Sprinting", description: "As Dead Man Walking, but you may more more quickly, mimicing the movements and sounds of a Zoombie.", minInfection: "75", skillTypeId: 3, skillCategoryId: 13),
        SkillModel(id: 27, xpCost: "4", prestigeCost: "0", name: "Gambler's Eye", description: "Double Advantage on coins and dice.", minInfection: "0", skillTypeId: 3, skillCategoryId: 8),
        SkillModel(id: 29, xpCost: "2", prestigeCost: "0", name: "Gambler's Luck", description: "Advantage on coins and dice.", minInfection: "0", skillTypeId: 3, skillCategoryId: 8),
        SkillModel(id: 68, xpCost: "3", prestigeCost: "1", name: "Regression", description: "-1 Infection per event", minInfection: "0", skillTypeId: 3, skillCategoryId: 14),
        SkillModel(id: 69, xpCost: "4", prestigeCost: "1", name: "Remission", description: "-1d4 Infection per event", minInfection: "0", skillTypeId: 3, skillCategoryId: 14),
        SkillModel(id: 93, xpCost: "2", prestigeCost: "0", name: "Will to Live", description: "Flip coin instead of rolling infection dice.", minInfection: "0", skillTypeId: 3, skillCategoryId: 7),
        SkillModel(id: 89, xpCost: "4", prestigeCost: "0", name: "Unshakable Resolve", description: "Get out of death free card.", minInfection: "0", skillTypeId: 3, skillCategoryId: 7),
        SkillModel(id: 4, xpCost: "4", prestigeCost: "0", name: "Anonymous Ally", description: "+1 Mysterious Stranger", minInfection: "0", skillTypeId: 3, skillCategoryId: 8),
        SkillModel(id: 54, xpCost: "1", prestigeCost: "0", name: "Mysterious Stranger", description: "+1 Mysterious Stranger", minInfection: "0", skillTypeId: 3, skillCategoryId: 8),
        SkillModel(id: 88, xpCost: "3", prestigeCost: "0", name: "Unknown Assailant", description: "+1 Mysterious Stranger", minInfection: "0", skillTypeId: 3, skillCategoryId: 8),
        SkillModel(id: 97, xpCost: "2", prestigeCost: "1", name: "Fortunate Find", description: "+items at checkin", minInfection: "0", skillTypeId: 3, skillCategoryId: 14),
        SkillModel(id: 98, xpCost: "4", prestigeCost: "1", name: "Prosperous Discovery", description: "+more items at checkin", minInfection: "0", skillTypeId: 3, skillCategoryId: 14),
        SkillModel(id: 11, xpCost: "4", prestigeCost: "0", name: "Combat Aficionado", description: "Combat -1, Talent +1", minInfection: "0", skillTypeId: 1, skillCategoryId: 15),
        SkillModel(id: 12, xpCost: "4", prestigeCost: "0", name: "Combat Specialist", description: "Combat -1, Profession +1", minInfection: "0", skillTypeId: 1, skillCategoryId: 15),
        SkillModel(id: 19, xpCost: "3", prestigeCost: "0", name: "Expert: Combat", description: "Combat -1", minInfection: "0", skillTypeId: 1, skillCategoryId: 15),
        SkillModel(id: 20, xpCost: "3", prestigeCost: "0", name: "Expert: Profession", description: "Profession -1", minInfection: "0", skillTypeId: 2, skillCategoryId: 15),
        SkillModel(id: 21, xpCost: "3", prestigeCost: "0", name: "Expert: Talent", description: "Talent -1", minInfection: "0", skillTypeId: 3, skillCategoryId: 15),
        SkillModel(id: 63, xpCost: "4", prestigeCost: "0", name: "Profession: Aficionado", description: "Profession -1, Talent +1", minInfection: "0", skillTypeId: 2, skillCategoryId: 15),
        SkillModel(id: 64, xpCost: "4", prestigeCost: "0", name: "Profession: Specialist", description: "Profession -1, Combat +1", minInfection: "0", skillTypeId: 2, skillCategoryId: 15),
        SkillModel(id: 74, xpCost: "4", prestigeCost: "0", name: "Talent: Aficionado", description: "Talent -1, Combat +1", minInfection: "0", skillTypeId: 3, skillCategoryId: 15),
        SkillModel(id: 75, xpCost: "4", prestigeCost: "0", name: "Talent: Specialist", description: "Talent -1, Profession +1", minInfection: "0", skillTypeId: 3, skillCategoryId: 15),
        SkillModel(id: 48, xpCost: "1", prestigeCost: "0", name: "Medium Firearm Proficiency", description: "Medium Firearm Wielding", minInfection: "0", skillTypeId: 1, skillCategoryId: 2),
        SkillModel(id: 40, xpCost: "1", prestigeCost: "0", name: "Light Firearm Dual Wielding", description: "Two light firearms at once", minInfection: "0", skillTypeId: 1, skillCategoryId: 3),
        SkillModel(id: 47, xpCost: "2", prestigeCost: "0", name: "Medium Firearm Dual Wielding", description: "Two medium firearms at once", minInfection: "0", skillTypeId: 1, skillCategoryId: 3),
        SkillModel(id: 100, xpCost: "4", prestigeCost: "1", name: "Fully Loaded", description: "Primary Firearm gets filled up to 25 bullets worth.", minInfection: "0", skillTypeId: 3, skillCategoryId: 14)
    ])

    var prereqs = SkillPrereqListModel(skillPrereqs: [
        SkillPrereqModel(id: 1, baseSkillId: 11, prereqSkillId: 20),
        SkillPrereqModel(id: 2, baseSkillId: 12, prereqSkillId: 21),
        SkillPrereqModel(id: 3, baseSkillId: 63, prereqSkillId: 19),
        SkillPrereqModel(id: 4, baseSkillId: 64, prereqSkillId: 21),
        SkillPrereqModel(id: 5, baseSkillId: 74, prereqSkillId: 20),
        SkillPrereqModel(id: 6, baseSkillId: 75, prereqSkillId: 19),
        SkillPrereqModel(id: 7, baseSkillId: 23, prereqSkillId: 1),
        SkillPrereqModel(id: 8, baseSkillId: 5, prereqSkillId: 61),
        SkillPrereqModel(id: 9, baseSkillId: 61, prereqSkillId: 16),
        SkillPrereqModel(id: 10, baseSkillId: 16, prereqSkillId: 15),
        SkillPrereqModel(id: 11, baseSkillId: 37, prereqSkillId: 38),
        SkillPrereqModel(id: 12, baseSkillId: 60, prereqSkillId: 80),
        SkillPrereqModel(id: 13, baseSkillId: 55, prereqSkillId: 60),
        SkillPrereqModel(id: 14, baseSkillId: 14, prereqSkillId: 13),
        SkillPrereqModel(id: 15, baseSkillId: 27, prereqSkillId: 29),
        SkillPrereqModel(id: 16, baseSkillId: 69, prereqSkillId: 68),
        SkillPrereqModel(id: 17, baseSkillId: 89, prereqSkillId: 93),
        SkillPrereqModel(id: 18, baseSkillId: 88, prereqSkillId: 54),
        SkillPrereqModel(id: 19, baseSkillId: 4, prereqSkillId: 88),
        SkillPrereqModel(id: 20, baseSkillId: 98, prereqSkillId: 97),
        SkillPrereqModel(id: 21, baseSkillId: 47, prereqSkillId: 40),
        SkillPrereqModel(id: 22, baseSkillId: 47, prereqSkillId: 48)
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
    
    var xpReductions = SpecialClassXpReductionListModel(specialClassXpReductions: [
        SpecialClassXpReductionModel(id: 1, characterId: 1, skillId: 23, xpReduction: "1"),
        SpecialClassXpReductionModel(id: 2, characterId: 1, skillId: 5, xpReduction: "2"),
        SpecialClassXpReductionModel(id: 2, characterId: 2, skillId: 55, xpReduction: "1"),
        SpecialClassXpReductionModel(id: 3, characterId: 3, skillId: 14, xpReduction: "1"),
        SpecialClassXpReductionModel(id: 3, characterId: 3, skillId: 89, xpReduction: "1")
    ])
                                                        
    var characterSkillList: CharacterSkillListModel {
        var cs = [CharacterSkillModel]()
        var incrementingId = 1
        for char in characterListFullModel.characters {
            cs.append(contentsOf: freeSkillsForCharacter(incrementingId: &incrementingId, characterId: char.id))
        }
        
        // Char 1
        cs.append(contentsOf: [
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 1, skillId: Constants.SpecificSkillIds.expertTalent),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 1, skillId: 5, relevantSpecialization: -1),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 1, skillId: 15, relevantSpecialization: -1),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 1, skillId: 16, relevantSpecialization: -1),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 1, skillId: 61, relevantSpecialization: -1),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 1, skillId: 1, relevantSpecialization: -1),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 1, skillId: 23, relevantSpecialization: -1),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 1, skillId: 100, relevantSpecialization: -1)
        ])
        
        // Char 2
        cs.append(contentsOf: [
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 2, skillId: Constants.SpecificSkillIds.expertCombat),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 2, skillId: Constants.SpecificSkillIds.professionAficionado_T),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 2, skillId: 37, relevantSpecialization: -1),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 2, skillId: 38, relevantSpecialization: -1),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 2, skillId: 55, relevantSpecialization: 1),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 2, skillId: 60, relevantSpecialization: 1),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 2, skillId: 80, relevantSpecialization: 1),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 2, skillId: 48, relevantSpecialization: -1),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 2, skillId: 40, relevantSpecialization: -1),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 2, skillId: 47, relevantSpecialization: -1),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 2, skillId: 100, relevantSpecialization: 1)
        ])
        
        // Char 3
        cs.append(contentsOf: [
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 3, skillId: 96),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 3, skillId: 13),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 3, skillId: 14),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 3, skillId: 27),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 3, skillId: 29),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 3, skillId: 68),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 3, skillId: 69),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 3, skillId: 93),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 3, skillId: 54),
            addSkillForCharacter(incrementingId: &incrementingId, characterId: 3, skillId: 100)
        ])
        
        return CharacterSkillListModel(charSkills: cs)
    }

    var events = EventListModel(events: [
        EventModel(id: 1, title: "Finished Event", description: "This event was finished", date: "2023/01/01", startTime: "4:00pm", endTime: "Midnight", isStarted: "TRUE", isFinished: "TRUE"),
        EventModel(id: 2, title: "Active Event", description: "This event is active", date: "2023/01/02", startTime: "4:00pm", endTime: "Midnight", isStarted: "TRUE", isFinished: "FALSE"),
        EventModel(id: 3, title: "Unstarted Event", description: "This event has not started yet", date: "2023/01/03", startTime: "4:00pm", endTime: "Midnight", isStarted: "FALSE", isFinished: "FALSE"),
    ])

    var eventAttendees = EventAttendeeListModel(eventAttendees: [
        EventAttendeeModel(id: 1, playerId: 1, characterId: 1, eventId: 1, isCheckedIn: "FALSE", asNpc: "FALSE"),
        EventAttendeeModel(id: 2, playerId: 2, characterId: 2, eventId: 1, isCheckedIn: "FALSE", asNpc: "FALSE"),
        EventAttendeeModel(id: 3, playerId: 3, characterId: 3, eventId: 1, isCheckedIn: "FALSE", asNpc: "FALSE"),
        EventAttendeeModel(id: 4, playerId: 1, characterId: nil, eventId: 1, isCheckedIn: "FALSE", asNpc: "FALSE"),
        EventAttendeeModel(id: 5, playerId: 4, characterId: 4, eventId: 1, isCheckedIn: "FALSE", asNpc: "FALSE"),
        EventAttendeeModel(id: 6, playerId: 2, characterId: 2, eventId: 2, isCheckedIn: "TRUE", asNpc: "FALSE"),
        EventAttendeeModel(id: 7, playerId: 3, characterId: 3, eventId: 2, isCheckedIn: "TRUE", asNpc: "FALSE"),
        EventAttendeeModel(id: 8, playerId: 4, characterId: 4, eventId: 2, isCheckedIn: "TRUE", asNpc: "TRUE")
    ])

    var contacts = ContactRequestListModel(contactRequests: [
        ContactRequestModel(id: 1, fullName: "John Doe", emailAddress: "test@test.test", postalCode: "54703", message: "This is a test contact message", read: "FALSE"),
        ContactRequestModel(id: 2, fullName: "Jane Dee", emailAddress: "jane@jane.jane", postalCode: "53959", message: "Please let me play still alive!", read: "TRUE")
    ])

    var intrigues = IntrigueListModel(intrigues: [
        IntrigueModel(id: 1, eventId: 1, investigatorMessage: "You will find something cool", interrogatorMessage: "You'll probably need a scavenger", webOfInformantsMessage: "This isn't used"),
        IntrigueModel(id: 2, eventId: 2, investigatorMessage: "Make sure you have Bash ready!", interrogatorMessage: "Gushers be afoot!", webOfInformantsMessage: "This isn't used"),
        IntrigueModel(id: 3, eventId: 3, investigatorMessage: "The Juggernaut is coming", interrogatorMessage: "Beware!", webOfInformantsMessage: "This isn't used")
    ])

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

    var gearList = GearListModel(charGear: [
        GearModel(id: 1, characterId: 1, gearJson: GearJsonListModel(gearJson: [
            GearJsonModel(name: "Hammerstrike", gearType: Constants.GearTypes.firearm, primarySubtype: Constants.GearPrimarySubtype.lightFirearm, secondarySubtype: Constants.GearSecondarySubtype.primaryFirearm, desc: "5 Shot Revolver")
        ]).toJsonString()!),
        GearModel(id: 2, characterId: 2, gearJson: GearJsonListModel(gearJson: [
            GearJsonModel(name: "Fireaxe", gearType: Constants.GearTypes.meleeWeapon, primarySubtype: Constants.GearPrimarySubtype.heavyMeleeWeapon, secondarySubtype: Constants.GearSecondarySubtype.none, desc: "Big fireaxe"),
            GearJsonModel(name: "Hammerstrike", gearType: Constants.GearTypes.firearm, primarySubtype: Constants.GearPrimarySubtype.lightFirearm, secondarySubtype: Constants.GearSecondarySubtype.none, desc: "5 Shot Revolver"),
            GearJsonModel(name: "Some Medium Gun", gearType: Constants.GearTypes.firearm, primarySubtype: Constants.GearPrimarySubtype.mediumFirearm, secondarySubtype: Constants.GearSecondarySubtype.none, desc: "A medium gun boi"),
            GearJsonModel(name: "Rattatat Boi", gearType: Constants.GearTypes.firearm, primarySubtype: Constants.GearPrimarySubtype.heavyFirearm, secondarySubtype: Constants.GearSecondarySubtype.none, desc: "A big rattatat boi with a lot of bullets"),
            GearJsonModel(name: "Alabaster Boi", gearType: Constants.GearTypes.firearm, primarySubtype: Constants.GearPrimarySubtype.heavyFirearm, secondarySubtype: Constants.GearSecondarySubtype.none, desc: "A big thicc boi with a lot of bullets"),
            GearJsonModel(name: "Thunderbow", gearType: Constants.GearTypes.firearm, primarySubtype: Constants.GearPrimarySubtype.mediumFirearm, secondarySubtype: Constants.GearSecondarySubtype.primaryFirearm, desc: "5 Shot Mega Bow")
        ]).toJsonString()!),
        GearModel(id: 3, characterId: 3, gearJson: GearJsonListModel(gearJson: [
            GearJsonModel(name: "Rhino", gearType: Constants.GearTypes.firearm, primarySubtype: Constants.GearPrimarySubtype.advancedFirearm, secondarySubtype: Constants.GearSecondarySubtype.none, desc: "Big ol boi"),
            GearJsonModel(name: "My Cool Bag", gearType: Constants.GearTypes.bag, primarySubtype: Constants.GearPrimarySubtype.largeBag, secondarySubtype: Constants.GearSecondarySubtype.none, desc: "A big ol bag")
        ]).toJsonString()!)
    ])
    
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
    
    var updateTracker = UpdateTrackerModel(id: 1, announcements: 1, awards: 1, characters: 1, gear: 1, characterSkills: 1, contactRequests: 1, events: 1, eventAttendees: 1, preregs: 1, featureFlags: 1, intrigues: 1, players: 1, profileImages: 1, researchProjects: 1, skills: 1, skillCategories: 1, skillPrereqs: 1, xpReductions: 1, campStatus: 1, rulebookVersion: "1.1.1.1", treatingWoundsVersion: "1.1.1.1")
    
    let skillCategories: SKillCategoryListModel = SKillCategoryListModel(results: [
        SkillCategoryModel(id: 1, name: "Beginner (Free) Skills"),
        SkillCategoryModel(id: 2, name: "Firearms"),
        SkillCategoryModel(id: 3, name: "Dual Wielding"),
        SkillCategoryModel(id: 4, name: "Melee"),
        SkillCategoryModel(id: 5, name: "Deconstruction"),
        SkillCategoryModel(id: 6, name: "Combat Techniques"),
        SkillCategoryModel(id: 7, name: "Resistance and Resolve"),
        SkillCategoryModel(id: 8, name: "Deus Ex Machina"),
        SkillCategoryModel(id: 9, name: "Mutualism"),
        SkillCategoryModel(id: 10, name: "Gathering"),
        SkillCategoryModel(id: 11, name: "Crafting and Repair"),
        SkillCategoryModel(id: 12, name: "Medicine"),
        SkillCategoryModel(id: 13, name: "The Infected"),
        SkillCategoryModel(id: 14, name: "Prestige"),
        SkillCategoryModel(id: 15, name: "Specialization")
    ])

    private func freeSkillsForCharacter(incrementingId: inout Int, characterId: Int) -> [CharacterSkillModel] {
        var cs = [CharacterSkillModel]()
        for skill in skills.results.filter({ $0.xpCost == "0" }) {
            cs.append(CharacterSkillModel(id: incrementingId, characterId: characterId, skillId: skill.id, xpSpent: 0, fsSpent: 0, ppSpent: 0))
            incrementingId += 1
        }
        return cs
    }
    
    private func addSkillForCharacter(incrementingId: inout Int, characterId: Int, skillId: Int, useFreeT1SkillsIfPossible: Bool = true, relevantSpecialization: Int = 0) -> CharacterSkillModel {
        let skill = skills.results.first(where: { $0.id == skillId })!
        var xpCost = skill.xpCost.intValueDefaultZero
        let ppCost = skill.prestigeCost.intValueDefaultZero
        var fsCost = 0
        
        if skill.xpCost.intValueDefaultZero == 0 && useFreeT1SkillsIfPossible {
            fsCost = 1
            xpCost = 0
        } else {
            for xpRed in xpReductions.specialClassXpReductions.filter({ $0.characterId == characterId && $0.skillId == skillId }) {
                xpCost = max(xpCost - xpRed.xpReduction.intValueDefaultZero, 1)
            }
            
            xpCost = max(xpCost + relevantSpecialization, 1)
        }
        
        let csm = CharacterSkillModel(id: incrementingId, characterId: characterId, skillId: skillId, xpSpent: xpCost, fsSpent: fsCost, ppSpent: ppCost)
        
        incrementingId += 1
        
        return csm
    }
    
}
