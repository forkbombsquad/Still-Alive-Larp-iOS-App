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
    var allAnnouncements: AnnouncementFullListModel { get }
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
    var xpReductions: XpReductionListModel { get }
    var preregs: EventPreregListModel { get }
    var version: AppVersionModel { get }
    var gearList: GearListModel { get }
    var featureFlagList: FeatureFlagListModel { get }
    var profileImageModel: ProfileImageModel { get }
    var profileImageList: ProfileImageListModel { get }
    var researchProjects: ResearchProjectListModel { get }
    var rulebook: Rulebook { get }
    var skillCategories: SKillCategoryListModel { get }
    var updateTracker: UpdateTrackerModel { get }
    var campStatus: CampStatusModel { get }
    var craftingRecipes: CraftingRecipeListModel { get }
}

extension MockData {
    
    func player(_ index: Int = 0) -> PlayerModel {
        return playerList.players[index]
    }
    
    func player(id: Int) -> PlayerModel {
        return playerList.players.first(where: { $0.id == id } )!
    }
    
    func fullPlayers() -> [FullPlayerModel] {
        var fps = [FullPlayerModel]()
        for player in playerList.players {
            fps.append(FullPlayerModel(player: player, characters: fullCharacters().filter({ $0.playerId == player.id }), awards: awards.awards.filter({ $0.playerId == player.id }), eventAttendees: eventAttendees.eventAttendees.filter({ $0.playerId == player.id }), preregs: preregs.eventPreregs.filter({ $0.playerId == player.id }), profileImage: profileImageModel))
        }
        return fps
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
        for character in characterListFullModel.characters {
            let fc = FullCharacterModel(character: character, allSkills: fullSkills(), charSkills: characterSkillList.charSkills.filter({ $0.characterId == character.id }), awards: awards.awards.filter({ $0.characterId == character.id }), eventAttendees: eventAttendees.eventAttendees.filter({ $0.characterId == character.id }), preregs: preregs.eventPreregs.filter({ $0.getCharId() == character.id }), xpReductions: xpReductions.specialClassXpReductions.filter({ $0.characterId == character.id }))
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
            fs.append(FullSkillModel(skillModel: skill, prereqs: skills.results.filter({ $0.id.equalsAnyOf(prereqs.skillPrereqs.filter({ preq in preq.baseSkillId == skill.id }).map({ preq in preq.baseSkillId })) }), postreqs: skills.results.filter({ $0.id.equalsAnyOf(prereqs.skillPrereqs.filter({ preq in preq.prereqSkillId == skill.id }).map({ preq in preq.prereqSkillId })) }), category: SkillCategoryModel(id: skill.skillCategoryId, name: skillCategories.results.first(where: { $0.id == skill.skillCategoryId })?.name ?? "")))
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
    
    func fullEvents() -> [FullEventModel] {
        var fe = [FullEventModel]()
        for event in events.events {
            fe.append(FullEventModel(event: event, attendees: eventAttendees.eventAttendees.filter({ $0.eventId == event.id }), preregs: preregs.eventPreregs.filter({ $0.eventId == event.id }), intrigue: intrigue()))
        }
        return fe
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
    
    func intriguesByEvent() -> [Int : IntrigueModel] {
        var ints = [Int : IntrigueModel]()
        for intrigue in intrigues.intrigues {
            ints[intrigue.eventId] = intrigue
        }
        return ints
    }
    
    func xpReduction(_ index: Int = 0) -> XpReductionModel {
        return xpReductions.specialClassXpReductions[index]
    }
    
    func xpReduction(id: Int) -> XpReductionModel {
        return xpReductions.specialClassXpReductions.first(where: { $0.id == id })!
    }
    
    func xpReduction(characterId: Int, skillId: Int) -> XpReductionModel {
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

    func craftingRecipe(_ index: Int = 0) -> CraftingRecipeModel {
        return craftingRecipes.craftingRecipes[index]
    }

    func craftingRecipe(id: Int) -> CraftingRecipeModel {
        return craftingRecipes.craftingRecipes.first(where: { $0.id == id })!
    }

    func fullCraftingRecipes() -> [FullCraftingRecipeModel] {
        var fcr = [FullCraftingRecipeModel]()
        for recipe in craftingRecipes.craftingRecipes {
            let requiredSkill = fullSkills().first { $0.id == recipe.skillId ?? -1 }
            let baseRecipe = recipe.baseRecipeId != nil && recipe.baseRecipeId != -1 ?
                fcr.first { $0.id == recipe.baseRecipeId } : nil

            var otherRefs = [FullCraftingRecipeModel]()
            for refId in recipe.getOtherRecipeIds() {
                if let ref = fcr.first(where: { $0.id == refId }) {
                    otherRefs.append(ref)
                }
            }

            fcr.append(FullCraftingRecipeModel(
                craftingRecipe: recipe,
                requiredSkill: requiredSkill,
                baseRecipe: baseRecipe?.craftingRecipe,
                otherRecipeReferences: otherRefs
            ))
        }
        return fcr
    }

    func playerCheckInBarcodeModel(playerId: Int = 1, characterId: Int? = nil, eventId: Int = 1) -> CheckInOutBarcodeModel {
        return CheckInOutBarcodeModel(playerId: playerId, characterId: characterId, eventId: eventId)
    }
    
    func playerCheckOutBarcodeModel(eventAttendeeId: Int = 1) -> CheckInOutBarcodeModel {
        let attendee = eventAttendee(id: eventAttendeeId)
        return CheckInOutBarcodeModel(playerId: attendee.playerId, characterId: attendee.characterId, eventId: attendee.eventId)
    }
    
    func getResponse(_ request: MockRequest) -> Codable {
        switch request.endpoint {
            case .playerSignIn, .player, .playerCreate, .awardPlayer, .updateP, .updatePAdmin, .updatePlayer, .deletePlayer:
                return player()
            case .authToken, .playerAuthToken:
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
        case .allAnnouncements:
            return allAnnouncements
        case .campStatus:
            return campStatus
        case .allFullCharacters:
            return fullCharacters()
        case .getAllCharacterSkills, .deleteCharacterSkill:
            return characterSkillList
        case .allEventAttendees:
            return eventAttendees
        case .getAllXpReductions:
            return xpReductions
        case .allPreregs:
            return preregs
        case .getAllProfileImages:
            return profileImageList
        case .getAllCraftingRecipes:
            return craftingRecipes
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
    var profileImageList = ProfileImageListModel(profileImages: [
        ProfileImageModel(id: 0, playerId: 1, image: "TEST"),
        ProfileImageModel(id: 1, playerId: 2, image: "TEST 2")
    ])

    var oauthToken = OAuthTokenResponse(access_token: "TestAccessToken")

    var announcementsList = AnnouncementsListModel(announcements: [AnnouncementSubModel(id: 1)])
    var allAnnouncements = AnnouncementFullListModel(announcements: [
        AnnouncementModel(id: 1, title: "Test Announcement", text: "This is a test announcment with mock data yo.", date: "2022/12/23"),
        AnnouncementModel(id: 2, title: "Test Announcement 2", text: "This is a test announcment with mock data yo but it's different than the first one.", date: "2023/12/23")
    ])
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
    
    var xpReductions = XpReductionListModel(specialClassXpReductions: [
        XpReductionModel(id: 1, characterId: 1, skillId: 23, xpReduction: "1"),
        XpReductionModel(id: 2, characterId: 1, skillId: 5, xpReduction: "2"),
        XpReductionModel(id: 2, characterId: 2, skillId: 55, xpReduction: "1"),
        XpReductionModel(id: 3, characterId: 3, skillId: 14, xpReduction: "1"),
        XpReductionModel(id: 3, characterId: 3, skillId: 89, xpReduction: "1")
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
        EventAttendeeModel(id: 1, playerId: 1, characterId: 1, eventId: 1, isCheckedIn: "FALSE", asNpc: "FALSE", npcId: -1),
        EventAttendeeModel(id: 2, playerId: 2, characterId: 2, eventId: 1, isCheckedIn: "FALSE", asNpc: "FALSE", npcId: -1),
        EventAttendeeModel(id: 3, playerId: 3, characterId: 3, eventId: 1, isCheckedIn: "FALSE", asNpc: "FALSE", npcId: -1),
        EventAttendeeModel(id: 4, playerId: 1, characterId: nil, eventId: 1, isCheckedIn: "FALSE", asNpc: "FALSE", npcId: -1),
        EventAttendeeModel(id: 5, playerId: 4, characterId: 4, eventId: 1, isCheckedIn: "FALSE", asNpc: "FALSE", npcId: -1),
        EventAttendeeModel(id: 6, playerId: 2, characterId: 2, eventId: 2, isCheckedIn: "TRUE", asNpc: "FALSE", npcId: -1),
        EventAttendeeModel(id: 7, playerId: 3, characterId: 3, eventId: 2, isCheckedIn: "TRUE", asNpc: "FALSE", npcId: -1),
        EventAttendeeModel(id: 8, playerId: 4, characterId: 4, eventId: 2, isCheckedIn: "TRUE", asNpc: "TRUE", npcId: -1)
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
        ResearchProjectModel(id: 1, name: "Radio Tower Project", description: "Commander Davis's Radio Tower Project that the entire camp needs to pitch in for. It's big. It's bad. It's pretty neat. Spooky though.\n\nSome newline related stuff just cuz", milestones: 4, complete: "TRUE", milestoneDescs: "{\"milestoneDescs\":[{\"id\":\"1\",\"text\":\"Gathered all the materials for the radio tower.\"},{\"id\":\"2\",\"text\":\"Assembled the main tower structure.\"},{\"id\":\"3\",\"text\":\"Connected the power source.\"},{\"id\":\"4\",\"text\":\"First broadcast received! We are not alone...\"}]}"),
        ResearchProjectModel(id: 2, name: "Curing the Infection", description: "This probably won't happen. No one is even working on it.", milestones: 0, complete: "FALSE", milestoneDescs: "{\"milestoneDescs\":[]}")
    ])
    
    var campStatus = CampStatusModel(id: 0, campFortifications: [CampFortification(ring: 1, fortifications: [Fortification(type: "MEDIUM", health: 10)])])

    var craftingRecipes = CraftingRecipeListModel(craftingRecipes: [
        // Ammunition
        CraftingRecipeModel(id: 4, name: "Rocket", baseRecipeId: -1, skillId: 22, numProduced: 1, category: "Ammunition", craftingTime: 5, wood: 2, metal: 2, cloth: 2, tech: 2, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        CraftingRecipeModel(id: 6, name: "Bullets", baseRecipeId: -1, skillId: 10, numProduced: 10, category: "Ammunition", craftingTime: 5, wood: 0, metal: 5, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        CraftingRecipeModel(id: 7, name: "Repacked", baseRecipeId: 6, skillId: 10, numProduced: 10, category: "Ammunition", craftingTime: 5, wood: 0, metal: 3, cloth: 0, tech: 0, medical: 0, casing: 10, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        CraftingRecipeModel(id: 9, name: "Megadarts", baseRecipeId: -1, skillId: 39, numProduced: 10, category: "Ammunition", craftingTime: 5, wood: 2, metal: 8, cloth: 8, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        CraftingRecipeModel(id: 10, name: "Repacked", baseRecipeId: 9, skillId: 39, numProduced: 10, category: "Ammunition", craftingTime: 5, wood: 1, metal: 5, cloth: 5, tech: 0, medical: 0, casing: 20, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        CraftingRecipeModel(id: 12, name: "Rivals", baseRecipeId: -1, skillId: 53, numProduced: 10, category: "Ammunition", craftingTime: 5, wood: 8, metal: 8, cloth: 5, tech: 5, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        CraftingRecipeModel(id: 13, name: "Repacked", baseRecipeId: 12, skillId: 53, numProduced: 10, category: "Ammunition", craftingTime: 5, wood: 5, metal: 5, cloth: 3, tech: 3, medical: 0, casing: 30, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        CraftingRecipeModel(id: 14, name: "Repacked", baseRecipeId: 4, skillId: 22, numProduced: 1, category: "Ammunition", craftingTime: 5, wood: 1, metal: 1, cloth: 1, tech: 1, medical: 0, casing: 5, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        // Tools and Traps
        CraftingRecipeModel(id: 17, name: "Explosive Charge", baseRecipeId: -1, skillId: 22, numProduced: 1, category: "Tools and Traps", craftingTime: 10, wood: 2, metal: 15, cloth: 8, tech: 8, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "An explosive designed to destory Infection Sites.\r\n\r\nSpecial: This  still needs to be placed by a Tinkerer with 5 minutes of work."),
        CraftingRecipeModel(id: 18, name: "Rocket Rigged", baseRecipeId: 17, skillId: 22, numProduced: 1, category: "Tools and Traps", craftingTime: 5, wood: 1, metal: 3, cloth: 1, tech: 1, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[{\"id\":4,\"num\":1}],\"foods\":[]}", desc: ""),
        CraftingRecipeModel(id: 45, name: "Juggernaut Snare Trap", baseRecipeId: -1, skillId: 78, numProduced: 1, category: "Tools and Traps", craftingTime: 10, wood: 2, metal: 2, cloth: 5, tech: 2, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "A 10' circular trap that entangles the Juggernaut, preventing him from running and charging until he breaks the bonds.\r\n\r\nSpecial: This  still needs to be placed by a Tinkerer with 5 minutes of work."),
        CraftingRecipeModel(id: 46, name: "Juggernaut Confusion Trap", baseRecipeId: -1, skillId: 78, numProduced: 1, category: "Tools and Traps", craftingTime: 10, wood: 1, metal: 1, cloth: 0, tech: 0, medical: 5, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "A 10' circular trap that confuses the Juggernaut, causing him to attack whatever is closest to him, rather than just us.\r\n\r\nSpecial: This  still needs to be placed by a Tinkerer with 5 minutes of work."),
        CraftingRecipeModel(id: 47, name: "Juggernaut Elemental Trap: Sustained Flame", baseRecipeId: -1, skillId: 78, numProduced: 1, category: "Tools and Traps", craftingTime: 10, wood: 7, metal: 3, cloth: 3, tech: 1, medical: 2, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "A 10' circular trap that engulfs the Juggernaut in flames and  leaves him partially vulernable to damage. One of the 3 types Elemental Traps required to actually kill him.\r\n\r\nSpecial: This  still needs to be placed by a Tinkerer with 5 minutes of work."),
        CraftingRecipeModel(id: 48, name: "Juggernaut Elemental Trap: Large-Scale Explosives", baseRecipeId: -1, skillId: 78, numProduced: 1, category: "Tools and Traps", craftingTime: 10, wood: 0, metal: 1, cloth: 5, tech: 5, medical: 5, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "A 10' circular trap that explosively tears into the juggernaut's plated skin and leaves him partially vulernable to damage. One of the 3 types Elemental Traps required to actually kill him.\r\n\r\nSpecial: This  still needs to be placed by a Tinkerer with 5 minutes of work."),
        CraftingRecipeModel(id: 49, name: "Juggernaut Elemental Trap: Electric Shock", baseRecipeId: -1, skillId: 78, numProduced: 1, category: "Tools and Traps", craftingTime: 10, wood: 1, metal: 8, cloth: 0, tech: 5, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "A 10' circular trap that explosively tears into the juggernaut's plated skin and leaves him partially vulernable to damage. One of the 3 types Elemental Traps required to actually kill him.\r\n\r\nSpecial: This  still needs to be placed by a Tinkerer with 5 minutes of work."),
        // Armor
        CraftingRecipeModel(id: 19, name: "Standard Armor", baseRecipeId: -1, skillId: 78, numProduced: 1, category: "Armor", craftingTime: 5, wood: 3, metal: 5, cloth: 1, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "Blue-Beaded Armor that blocks melee damage but not firearm damage."),
        CraftingRecipeModel(id: 20, name: "Bullet-Proof Armor", baseRecipeId: -1, skillId: 44, numProduced: 1, category: "Armor", craftingTime: 10, wood: 5, metal: 8, cloth: 2, tech: 4, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "Red-Beaded Armor that blocks melee damage and firearm damage."),
        // Fortifications
        CraftingRecipeModel(id: 21, name: "Light Fortification", baseRecipeId: -1, skillId: 78, numProduced: 1, category: "Fortifications", craftingTime: 1, wood: 5, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "Maximum Health: 5"),
        CraftingRecipeModel(id: 22, name: "Medium Fortification", baseRecipeId: -1, skillId: 78, numProduced: 1, category: "Fortifications", craftingTime: 2, wood: 5, metal: 5, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "Maximum Health: 10"),
        CraftingRecipeModel(id: 23, name: "Heavy Fortification", baseRecipeId: -1, skillId: 78, numProduced: 1, category: "Fortifications", craftingTime: 3, wood: 10, metal: 5, cloth: 5, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "Maximum Health: 15"),
        CraftingRecipeModel(id: 24, name: "Advanced Fortification", baseRecipeId: -1, skillId: 44, numProduced: 1, category: "Fortifications", craftingTime: 5, wood: 10, metal: 10, cloth: 5, tech: 5, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "Maximum Health: 20"),
        CraftingRecipeModel(id: 25, name: "Military Grade Fortification", baseRecipeId: -1, skillId: 44, numProduced: 1, category: "Fortifications", craftingTime: 10, wood: 15, metal: 15, cloth: 10, tech: 10, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "Maximum Health: 10"),
        // Firearms
        CraftingRecipeModel(id: 26, name: "Light Firearm", baseRecipeId: -1, skillId: 31, numProduced: 1, category: "Firearms", craftingTime: 1, wood: 1, metal: 1, cloth: 1, tech: 1, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        CraftingRecipeModel(id: 27, name: "Medium Firearm", baseRecipeId: -1, skillId: 31, numProduced: 1, category: "Firearms", craftingTime: 2, wood: 2, metal: 2, cloth: 1, tech: 2, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        CraftingRecipeModel(id: 28, name: "Heavy Firearm", baseRecipeId: -1, skillId: 31, numProduced: 1, category: "Firearms", craftingTime: 3, wood: 3, metal: 4, cloth: 2, tech: 3, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        CraftingRecipeModel(id: 29, name: "Advanced Firearm", baseRecipeId: -1, skillId: 31, numProduced: 1, category: "Firearms", craftingTime: 5, wood: 4, metal: 8, cloth: 2, tech: 4, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        CraftingRecipeModel(id: 30, name: "Military Grade Firearm", baseRecipeId: -1, skillId: 52, numProduced: 1, category: "Firearms", craftingTime: 10, wood: 5, metal: 16, cloth: 3, tech: 8, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        // Gear
        CraftingRecipeModel(id: 31, name: "Small Bag", baseRecipeId: -1, skillId: 78, numProduced: 1, category: "Gear", craftingTime: 1, wood: 0, metal: 0, cloth: 1, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "A bag or pouch with a capacity of 0.5 liters (30.5cu in) or less"),
        CraftingRecipeModel(id: 32, name: "Medium Bag", baseRecipeId: -1, skillId: 78, numProduced: 1, category: "Gear", craftingTime: 2, wood: 0, metal: 0, cloth: 3, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "A bag or pouch with a capacity of between 0.5 liters (30.5cu in) and 5 liters (305.1cu in)"),
        CraftingRecipeModel(id: 33, name: "Large Bag", baseRecipeId: -1, skillId: 78, numProduced: 1, category: "Gear", craftingTime: 5, wood: 0, metal: 0, cloth: 7, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "A bag or pouch with a capacity of between 5 liters (305.1cu in) and 25 liters (1,525.6cu in)"),
        CraftingRecipeModel(id: 34, name: "Extra Large Bag", baseRecipeId: -1, skillId: 44, numProduced: 1, category: "Gear", craftingTime: 10, wood: 0, metal: 0, cloth: 13, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "A bag or pouch with a capacity of more than 25 liters (1,525.6cu in)"),
        CraftingRecipeModel(id: 35, name: "Clothing", baseRecipeId: -1, skillId: 78, numProduced: 1, category: "Gear", craftingTime: 2, wood: 0, metal: 0, cloth: 2, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "This recipe is for Mechanically Advantageous clothing such as Cargo Shorts or a Coat with many pockets. Regular clothing does not need to be crafted in this game. If your clothing piece would come in a pair (such as gloves or boots), you craft both parts of the pair."),
        CraftingRecipeModel(id: 36, name: "Flashlight", baseRecipeId: -1, skillId: 78, numProduced: 1, category: "Gear", craftingTime: 2, wood: 0, metal: 2, cloth: 0, tech: 1, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "This recipe works for both regular flashlights and blacklight flashlights."),
        CraftingRecipeModel(id: 37, name: "Custom Accessory", baseRecipeId: -1, skillId: 78, numProduced: 1, category: "Gear", craftingTime: -1, wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "This recipe is special in that it covers all different types of miscellaneous Technically Advantageous accessory items you may want to bring into the game. You always need to talk to a Game Runner to make sure that your Accessory is approved and to get the final crafting recipe for it, but under most circumstances, the recipe for an Accessory just consists of the materials that make it up:\r\n\r\n- If your Accessory contains metal, 1 metal is required.\r\n- If it contains a textile (such as cloth, leather, polyester, etc), 1 cloth is required.\r\n- If it contains wood or other non-metal, non-textile solid materials (such as plastic, resin, glass, etc), 1 wood is required.\r\n- If it contains circuitry or mechanical parts, 1 tech is required.\r\n\r\nNote - If your Accessory only requires one material to craft it, add 1 of that material to the cost - all Accessories cost at least 2 materials to craft."),
        // Melee Weapons
        CraftingRecipeModel(id: 38, name: "Super Light Melee Weapon", baseRecipeId: -1, skillId: 91, numProduced: 1, category: "Melee Weapons", craftingTime: 1, wood: 1, metal: 3, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        CraftingRecipeModel(id: 39, name: "Light Melee Weapon", baseRecipeId: -1, skillId: 91, numProduced: 1, category: "Melee Weapons", craftingTime: 2, wood: 2, metal: 5, cloth: 1, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        CraftingRecipeModel(id: 40, name: "Medium Melee Weapon", baseRecipeId: -1, skillId: 91, numProduced: 1, category: "Melee Weapons", craftingTime: 5, wood: 2, metal: 9, cloth: 2, tech: 1, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        CraftingRecipeModel(id: 41, name: "Heavy Melee Weapon", baseRecipeId: -1, skillId: 7, numProduced: 1, category: "Melee Weapons", craftingTime: 10, wood: 3, metal: 17, cloth: 3, tech: 2, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        // Pharmaceuticals
        CraftingRecipeModel(id: 42, name: "Adreanaline", baseRecipeId: -1, skillId: 62, numProduced: 1, category: "Pharmaceuticals", craftingTime: 5, wood: 0, metal: 1, cloth: 0, tech: 0, medical: 5, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "Typical Market Price: 30 Bullets\r\n\r\nAdreanaline (pronounced Uh-dree-nuh-line) is represented by small orange candies (such as Tic-Tacs).\r\n\r\nWhen taken, The user ignores the effects of all Wounds and Fatal Wounds for 1 Encounter, giving them the full use of their limbs and preventing them from gaining the Helpless condition. The user still gains these injuries as normal, they just ignore all the effects until the Encounter is finished, after which they immediately feel all of their injuries at once.\r\n\r\nImportant Notes: Even though you don't feel your injuries and can't gain the Helpless condition, you still have them and thus are still susceptible to dying from a gunshot to the Torso while you have a Fatal Wound. You can also still be dragged to the ground by zombies who are grabbing you as normal."),
        CraftingRecipeModel(id: 43, name: "Bulk", baseRecipeId: 42, skillId: 62, numProduced: 5, category: "Pharmaceuticals", craftingTime: 10, wood: 0, metal: 3, cloth: 0, tech: 0, medical: 20, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: ""),
        // Recycling
        CraftingRecipeModel(id: 44, name: "Metal Reclamation", baseRecipeId: -1, skillId: 78, numProduced: 1, category: "Recycling", craftingTime: 1, wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 10, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "Turn your Bullet Casings into Metal!"),
        CraftingRecipeModel(id: 64, name: "Alternate Skillset", baseRecipeId: 44, skillId: 10, numProduced: 1, category: "Recycling", craftingTime: 1, wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 10, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[]}", desc: "Turn your Bullet Casings into Metal!"),
        // Dishes and Food
        CraftingRecipeModel(id: 50, name: "Flour", baseRecipeId: -1, skillId: 116, numProduced: 1, category: "Dishes and Food", craftingTime: 1, wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[{\"wheat\":2}]}", desc: "Steps From Harvest To Completion: 1 (+0/1)\r\nBase Food Value: 2\r\nTypical Market Price: 5"),
        CraftingRecipeModel(id: 51, name: "Fruit Preserves", baseRecipeId: -1, skillId: 116, numProduced: 1, category: "Dishes and Food", craftingTime: 2, wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[{\"fruit\":2}]}", desc: "Steps From Harvest To Completion: 1 (+0/1)\r\nBase Food Value: 2\r\nTypical Market Price: 3\r\nFavorite Dish Of: Airman Wylder"),
        CraftingRecipeModel(id: 52, name: "Filleted Fish", baseRecipeId: -1, skillId: 116, numProduced: 1, category: "Dishes and Food", craftingTime: 1, wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[{\"fish\":2}]}", desc: "Steps From Harvest To Completion: 1 (+0/1)\r\nBase Food Value: 2\r\nTypical Market Price: 7"),
        CraftingRecipeModel(id: 53, name: "Boiled Potatoes", baseRecipeId: -1, skillId: 116, numProduced: 1, category: "Dishes and Food", craftingTime: 2, wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[{\"potato\":2}]}", desc: "Steps From Harvest To Completion: 1 (+0/1)\r\nBase Food Value: 2\r\nTypical Market Price: 5"),
        CraftingRecipeModel(id: 54, name: "Baked Fish Dinner", baseRecipeId: -1, skillId: 116, numProduced: 1, category: "Dishes and Food", craftingTime: 3, wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[{\"id\":53,\"num\":1},{\"id\":52,\"num\":1}],\"foods\":[]}", desc: "Steps From Harvest To Completion: 3  (+1/2)\r\nBase Food Value: 5\r\nTypical Market Price: 14"),
        CraftingRecipeModel(id: 55, name: "Bread", baseRecipeId: -1, skillId: 116, numProduced: 1, category: "Dishes and Food", craftingTime: 3, wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[{\"id\":50,\"num\":2}],\"foods\":[]}", desc: "Steps From Harvest To Completion: 3  (+1/2)\r\nBase Food Value: 5\r\nTypical Market Price: 12\r\nFavorite Dish Of: Sargent Gantz"),
        CraftingRecipeModel(id: 56, name: "Fish Sandwich", baseRecipeId: -1, skillId: 116, numProduced: 1, category: "Dishes and Food", craftingTime: 5, wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[{\"id\":55,\"num\":1},{\"id\":52,\"num\":1}],\"foods\":[]}", desc: "Steps From Harvest To Completion: 5  (+2/3)\r\nBase Food Value: 9\r\nTypical Market Price: 22"),
        CraftingRecipeModel(id: 57, name: "Potato Salad", baseRecipeId: -1, skillId: 116, numProduced: 1, category: "Dishes and Food", craftingTime: 3, wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[{\"id\":53,\"num\":2}],\"foods\":[]}", desc: "Steps From Harvest To Completion: 3 (+1/2)\r\nBase Food Value: 5\r\nTypical Market Price: 12"),
        CraftingRecipeModel(id: 58, name: "Toast and Jelly", baseRecipeId: -1, skillId: 116, numProduced: 1, category: "Dishes and Food", craftingTime: 2, wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[{\"id\":55,\"num\":1},{\"id\":51,\"num\":1}],\"foods\":[]}", desc: "Steps From Harvest To Completion: 5  (+2/3)\r\nBase Food Value: 9\r\nTypical Market Price: 18"),
        CraftingRecipeModel(id: 59, name: "Fish and Chips", baseRecipeId: -1, skillId: 117, numProduced: 1, category: "Dishes and Food", craftingTime: 5, wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[{\"id\":52,\"num\":1},{\"id\":50,\"num\":1}],\"foods\":[{\"potato\":1}]}", desc: "Steps From Harvest To Completion: 3 (+2/3)\r\nBase Food Value: 7\r\nTypical Market Price: 17\r\nFavorite Meal Of: Commander Davis"),
        CraftingRecipeModel(id: 60, name: "Fish Stew", baseRecipeId: -1, skillId: 117, numProduced: 1, category: "Dishes and Food", craftingTime: 5, wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[],\"foods\":[{\"potato\":1, \"fish\":2}]}", desc: "Steps From Harvest To Completion: 1  (+1/2)\r\nBase Food Value: 4 \r\nTypical Market Price: 10"),
        CraftingRecipeModel(id: 61, name: "Charcuterie", baseRecipeId: -1, skillId: 117, numProduced: 1, category: "Dishes and Food", craftingTime: 5, wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[{\"id\":55,\"num\":1}],\"foods\":[{\"fruit\":2}]}", desc: "Steps From Harvest To Completion: 4  (+3/3)\r\nBase Food Value: 10\r\nTypical Market Price: 17"),
        CraftingRecipeModel(id: 62, name: "Fish Pie", baseRecipeId: -1, skillId: 117, numProduced: 1, category: "Dishes and Food", craftingTime: 5, wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[{\"id\":53,\"num\":1},{\"id\":52,\"num\":1},{\"id\":55,\"num\":1}],\"foods\":[]}", desc: "Steps From Harvest To Completion: 6  (+4/4)\r\nBase Food Value: 13\r\nTypical Market Price: 28"),
        CraftingRecipeModel(id: 63, name: "Mashed Potatoes", baseRecipeId: -1, skillId: 117, numProduced: 1, category: "Dishes and Food", craftingTime: 3, wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, casing: 0, otherRequiredItemIds: "{\"otherItemIds\":[{\"id\":53,\"num\":3}],\"foods\":[]}", desc: "Steps From Harvest To Completion: 4  (+3/3)\r\nBase Food Value: 9\r\nTypical Market Price: 18")
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
        ]),
        Heading(title: "Downtime",
                textsAndTables: [
                    "Most of the Event will take place in Downtime, during which, characters are free to explore the land, complete quests and jobs, gather resources, and pretty much do whatever they would like (within reason). All of the following sub-sections explain the different things that are possible during downtime (besides simply exploring the land) should you wish to do something more productive! Downtime is your opportunity to accomplish whatever it is you would like to accomplish during the event.",
                    "Remember, generally the Daytime is safer than the Nighttime, so if you want to do a lot of work away from camp, plan your time accordingly."
                ], subSubHeadings: [], subHeadings: [
                    SubHeading("Camp Facilities", textsAndTables: [
                        "There are several facilities at Camp that are free to be used by all Camp Survivors should the need arise. Though there is limited space, there exists potential for expansion in the future."
                    ], subSubHeadings: [
                        SubSubHeading("The Teaching Area", textsAndTables: [
                            "The Teaching Area is where you will need to learn any \n<font color=\'#910016\'>\n Combat\n</font> or \n<font color=\'#0D8017\'>\n Profession\n</font> type skills that you take after your first event. Someone with the approiate level of \n<b>\n Teaching\n</b> skill will help you learn your new abilities. It\'s important to pay them a bullet or two for their time. A single \n<b>\n Teacher\n</b> may only teach one class at once but they may have multiple students learning the same skill. Additionally, multiple \n<b>\n Teachers\n</b> can host classes at the same time. The limitation on this is the number of chairs in the classroom area. Each student needs one chair in order to be taught. If there are no available chairs, you will have to wait until one is available to learn your new skill."
                        ]),
                        SubSubHeading("Fortification Health and Destroying Fortifications", textsAndTables: [
                            "When a \n<i>\n Fortification\n</i> is constructed, it always starts with its \"Maximum Health\" value. Health of \n<i>\n Fortifications\n</i> is represented as pieces of wood that are Velcro\'d to the \n<i>\n Fortification\'s\n</i> surface. Each wood piece represents 1 Health. When a \n<i>\n Fortification\n</i> is damaged, one of the velcro\'d pieces of wood is removed. \n<i>\n Fortifications\n</i> can be Repaired so long as they have Health remaining. If all of a \n<i>\n Fortification\'s\n</i> Health is removed, that \n<i>\n Fortification\n</i> is destroyed and must be rebuilt. Check out the <a href=\"#Repair\">Repairing</a> section for more information about how to repair \n<i>\n Fortifications\n</i> that still have Health remaining.",
                            "Every entity in Still Alive has the ability to damage \n<i>\n Fortifications\n</i> with their own rules. Players, damage them using the \n<b>\n Bash\n</b>, \n<b>\n Smash\n</b> and \n<b>\n Crash\n</b> Skills (reminder that every Character starts with the \n<b>\n Bash\n</b> Skill for free). In order to start damaging a \n<i>\n Fortification\n</i>, you\'ll need a Melee Weapon (though you don\'t have to be proficient with it). Start roleplaying hitting the \n<i>\n Fortification\n</i> loudly making lots of noise while you are damaging it. If you have the \n<b>\n Smash\n</b> or \n<b>\n Crash\n</b> Skills, you are able to damage \n<i>\n Fortifications\n</i> quietly, but it takes more time. Use the table below to determine how much time it takes to damage a \n<i>\n Fortification\n</i> (allowing you to remove one of it\'s velcro\'d on wood pieces - i.e. it\'s Health).",
                            Table(contents: [
                                "" : ["<th>Regular Damage (loud)</th>", "<th>Quiet Damage</th>"],
                                "Bash" : ["30 Seconds", "-"],
                                "Smash" : ["20 Seconds", "1 Minute"],
                                "Crash" : ["10 Seconds", "30 Seconds"]
                            ])
                        ])
                    ])
                ])
    ])
    
    var updateTracker = UpdateTrackerModel(id: 1, announcements: 1, awards: 1, characters: 1, gear: 1, characterSkills: 1, contactRequests: 1, events: 1, eventAttendees: 1, preregs: 1, featureFlags: 1, intrigues: 1, players: 1, profileImages: 1, researchProjects: 1, skills: 1, skillCategories: 1, skillPrereqs: 1, xpReductions: 1, campStatus: 1, craftingRecipes: 1, rulebookVersion: "1.1.1.1", treatingWoundsVersion: "1.1.1.1")
    
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
            cs.append(CharacterSkillModel(id: incrementingId, characterId: characterId, skillId: skill.id, xpSpent: 0, fsSpent: 0, ppSpent: 0, date: "2025/06/01"))
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
        
        let csm = CharacterSkillModel(id: incrementingId, characterId: characterId, skillId: skillId, xpSpent: xpCost, fsSpent: fsCost, ppSpent: ppCost, date: "2025/06/01")
        
        incrementingId += 1
        
        return csm
    }
    
}
