//
//  CharacterModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/11/22.
//

import Foundation

enum CharacterType: Int, CaseIterable {
    case standard = 1
    case npc = 2
    case planner = 3
    case hidden = 4
}

struct FullCharacterListModel: CustomCodeable {
    let characters: [OldFullCharacterModel]
}

struct FullCharacterModel: CustomCodeable, Identifiable {
    let id: Int
    let fullName: String
    let startDate: String
    var isAlive: Bool
    let deathDate: String
    var infection: Int
    var bio: String
    var approvedBio: Bool
    var bullets: Int
    let megas: Int
    let rivals: Int
    let rockets: Int
    let bulletCasings: Int
    let clothSupplies: Int
    let woodSupplies: Int
    let metalSupplies: Int
    let techSupplies: Int
    let medicalSupplies: Int
    let armor: String
    let unshakableResolveUses: Int
    let mysteriousStrangerUses: Int
    let playerId: Int
    let characterTypeId: Int
    var gear: GearModel?
    let awards: [AwardModel]
    let eventAttendees: [EventAttendeeModel]
    let preregs: [EventPreregModel]
    let xpReductions: [SpecialClassXpReductionModel]
    
    private var skills: [FullCharacterModifiedSkillModel]
    
    init(character: CharacterModel, allSkills: [FullSkillModel], charSkills: [CharacterSkillModel], gear: GearModel? = nil, awards: [AwardModel], eventAttendees: [EventAttendeeModel], preregs: [EventPreregModel], xpReductions: [SpecialClassXpReductionModel]) {
        self.id = character.id
        self.fullName = character.fullName
        self.startDate = character.startDate
        self.isAlive = character.isAlive.boolValueDefaultFalse
        self.deathDate = character.deathDate
        self.infection = character.infection.intValueDefaultZero
        self.bio = character.bio
        self.approvedBio = character.approvedBio.boolValueDefaultFalse
        self.bullets = character.bullets.intValueDefaultZero
        self.megas = character.megas.intValueDefaultZero
        self.rivals = character.rivals.intValueDefaultZero
        self.rockets = character.rockets.intValueDefaultZero
        self.bulletCasings = character.bulletCasings.intValueDefaultZero
        self.clothSupplies = character.clothSupplies.intValueDefaultZero
        self.woodSupplies = character.woodSupplies.intValueDefaultZero
        self.metalSupplies = character.metalSupplies.intValueDefaultZero
        self.techSupplies = character.techSupplies.intValueDefaultZero
        self.medicalSupplies = character.medicalSupplies.intValueDefaultZero
        self.armor = character.armor
        self.unshakableResolveUses = character.unshakableResolveUses.intValueDefaultZero
        self.mysteriousStrangerUses = character.mysteriousStrangerUses.intValueDefaultZero
        self.playerId = character.playerId
        self.characterTypeId = character.characterTypeId
        self.gear = gear
        self.awards = awards
        self.eventAttendees = eventAttendees
        self.preregs = preregs
        self.xpReductions = xpReductions
        
        var fcmSkills = [FullCharacterModifiedSkillModel]()
        let pskills = allSkills.filter({ al in charSkills.first(where: { cs in al.id == cs.skillId }) != nil })
        for baseFullSkill in allSkills {
            let xpRed = xpReductions.first(where: { $0.skillId == baseFullSkill.id })
            let charSkill = charSkills.first(where: { $0.skillId == baseFullSkill.id })
            fcmSkills.append(
                FullCharacterModifiedSkillModel(skill: baseFullSkill,
                                                charSkillModel: charSkill,
                                                xpReduction: xpRed,
                                                combatXpMod: costOfCombatSkills(pskills),
                                                professionXpMod: costOfProfessionSkills(pskills),
                                                talentXpMod: costOfTalentSkills(pskills),
                                                inf50Mod: costOf50InfectSkills(pskills),
                                                inf75Mod: costOf75InfectSkills(pskills)
                                               )
                )
        }
        self.skills = fcmSkills
    }
    
    func isNpcAndNotAttendingEvent(eventId: Int) -> Bool {
        guard characterType() == .npc else { return false }
        return DataManager.shared.events.first(where: { $0.id == eventId })?.attendees.first(where: { $0.npcId == self.id }) == nil
    }
    
    func baseModel() -> CharacterModel {
        return CharacterModel(self)
    }
    
    func getPostText() -> String {
        switch characterType() {
        case .standard: return isAlive ? "Active" : "Inactive"
        case .npc: return isAlive ? "NPC" : "NPC - Deceased"
        case .planner: return "Planned"
        case .hidden: return ""
        }
    }
    
    func getSpentXp() -> Int {
        return allPurchasedSkills().sumOf({ $0.spentXp() })
    }
    
    func getSpentFt1s() -> Int {
        return allPurchasedSkills().sumOf({ $0.spentFt1s() })
    }
    
    func getSpentPp1s() -> Int {
        return allPurchasedSkills().sumOf({ $0.spentPp() })
    }
    
    func allSkillsWithCharacterModifications() -> [FullCharacterModifiedSkillModel] {
        return skills
    }
    
    func allPurchasedSkills() -> [FullCharacterModifiedSkillModel] {
        return skills.filter({ $0.isPurchased() })
    }
    
    func allNonPurchasedSkills() -> [FullCharacterModifiedSkillModel] {
        return skills.filter({ !$0.isPurchased() })
    }
    
    func attemptToPurchaseSkill(skill: FullCharacterModifiedSkillModel, completion: @escaping (_ success: Bool) -> Void) {
        // TODO
    }
    
    private func askToPurchase(skill: FullCharacterModifiedSkillModel, completion: @escaping (_ char: CharacterSkillCreateModel) -> Void) {
        // TODO
    }
    
    private func promptTOUseFt1s(title: String, completion: @escaping (_ useFt1s: Bool) -> Void) {
        // TODO
    }
    
    private func promptToPurchase(title: String, purchaseText: String, useFreeSkill: Bool, skill: FullCharacterModifiedSkillModel, completion: @escaping (_ charSkill: CharacterSkillCreateModel) -> Void) {
        // TODO
    }
    
    func allPurchaseableSkills(searchText: String = "", filter: SkillListView.FilterType = .none) -> [FullCharacterModifiedSkillModel] {
        // TODO
    }
    
    func couldPurchaseSkill(skill: FullCharacterModifiedSkillModel) -> Bool {
        guard !skill.isPurchased() else { return false }
        return allPurchaseableSkills().first(where: { $0.id == skill.id }) != nil
    }
    
    func characterType() -> CharacterType {
        return CharacterType(rawValue: characterTypeId) ?? .standard
    }
    
    func hasAllPrereqsForSkill(skill: FullCharacterModifiedSkillModel) -> Bool {
        let purchasedIds = allPurchasedSkills().map({ $0.id })
        return skill.prereqs().allSatisfy({ $0.id.equalsAnyOf(purchasedIds) })
    }
    
    func getPurchasedChooseOneSkills() -> [FullCharacterModifiedSkillModel] {
        return allPurchasedSkills().filter { skill in
            skill.id.equalsAnyOf(Constants.SpecificSkillIds.allSpecalistSkills)
        }
    }
    
    private func costOfCombatSkills(_ purchasedSkills: [FullSkillModel]) -> Int {
        for pskill in purchasedSkills {
            if pskill.id.equalsAnyOf(Constants.SpecificSkillIds.allCombatReducingSkills) {
                return -1
            }
            if pskill.id.equalsAnyOf(Constants.SpecificSkillIds.allCombatIncreasingSkills) {
                return 1
            }
        }
        return 0
    }
    
    private func costOfProfessionSkills(_ purchasedSkills: [FullSkillModel]) -> Int {
        for pskill in purchasedSkills {
            if pskill.id.equalsAnyOf(Constants.SpecificSkillIds.allProfessionReducingSkills) {
                return -1
            }
            if pskill.id.equalsAnyOf(Constants.SpecificSkillIds.allProfessionIncreasingSkills) {
                return 1
            }
        }
        return 0
    }
    
    private func costOfTalentSkills(_ purchasedSkills: [FullSkillModel]) -> Int {
        for pskill in purchasedSkills {
            if pskill.id.equalsAnyOf(Constants.SpecificSkillIds.allTalentReducingSkills) {
                return -1
            }
            if pskill.id.equalsAnyOf(Constants.SpecificSkillIds.allTalentIncreasingSkills) {
                return 1
            }
        }
        return 0
    }
    
    private func costOf50InfectSkills(_ purchasedSkills: [FullSkillModel]) -> Int {
        return purchasedSkills.first(where: { $0.id == Constants.SpecificSkillIds.adaptable }) != nil ? 25 : 50
    }
    
    private func costOf75InfectSkills(_ purchasedSkills: [FullSkillModel]) -> Int {
        return purchasedSkills.first(where: { $0.id == Constants.SpecificSkillIds.extremelyAdaptable }) != nil ? 50 : 75
    }
    
    func hasUnshakableResolve() -> Bool {
        return allPurchasedSkills().first(where: { $0.id == Constants.SpecificSkillIds.unshakableResolve }) != nil
    }
    
    func mysteriousStrangerCount() -> Int {
        var count = 0
        for pskill in allPurchasedSkills() {
            if pskill.id.equalsAnyOf(Constants.SpecificSkillIds.mysteriousStrangerTypeSkills) {
                count += 1
            }
        }
        return count
    }
    
    private func getLastAttendedEvent() -> FullEventModel? {
        guard eventAttendees.isNotEmpty else { return nil }
        // Step 1: Build a map from event IDs to Event objects
        let eventMap = Dictionary(uniqueKeysWithValues: DataManager.shared.events.map { ($0.id, $0) })
        let eventsWithAttendees = eventAttendees.compactMap { eventMap[$0.eventId] }

        // Step 3: Find the one with the latest date
        let latestEvent = eventsWithAttendees.max {
            $0.date.yyyyMMddtoDate() < $1.date.yyyyMMddtoDate()
        }

        return latestEvent
    }
    
    func getSkillsTakenSinceLastEvent() -> [FullCharacterModifiedSkillModel] {
        var skillsTaken = [FullCharacterModifiedSkillModel]()
        if let event = getLastAttendedEvent() {
            // Only add skills that have been added since the last event they attended.
            // If they've never attended, none need to be added
            skillsTaken = allPurchasedSkills().filter { $0.isNew(event: event) }
        }
        return skillsTaken
    }
    
    func getRelevantBarcodeSkills() -> [FullCharacterModifiedSkillModel] {
        var baseBarcodeSkills = [FullCharacterModifiedSkillModel]()
        for pskill in allPurchasedSkills() {
            if pskill.id.equalsAnyOf(Constants.SpecificSkillIds.barcodeRelevantSkills) {
                baseBarcodeSkills.append(pskill)
            }
        }
        return baseBarcodeSkills
    }
    
    func getGearOrganized() -> [String : [GearJsonModel]] {
        return gear?.getGearOrganized() ?? [:]
    }
    
    func getPurchasedSkillsFiltered(searchText: String, filter: SkillListView.FilterType) -> [FullCharacterModifiedSkillModel] {
        return allPurchasedSkills().filter({ $0.includeInFilter(searchText: searchText, filterType: filter) })
    }
    
    func getAwardsSorted() -> [AwardModel] {
        let sortedAwards = awards.sorted {
            return $0.date.yyyyMMddtoDate() > $1.date.yyyyMMddtoDate() // descending
        }
    }
    
    func deleteSkillsDESTRUCTIVE(completion: @escaping (_ success: Bool) -> Void) {
        // TODO
    }
    
    func deleteCharacterDESTRUCTIVE(completion: @escaping (_ success: Bool) -> Void) {
        // TODO
    }
    
    func getAllXpSpent() -> Int {
        return allPurchasedSkills().sumOf({ $0.spentXp() })
    }
    
    func getAllSpentPrestigePoints() -> Int {
        return allPurchasedSkills().sumOf({ $0.spentPp() })
    }
 
}

struct OldFullCharacterModel: CustomCodeable {
    // TODO get rid of this
    let id: Int
    let fullName: String
    let startDate: String
    let isAlive: String
    let deathDate: String
    let infection: String
    var bio: String
    var approvedBio: String
    let bullets: String
    let megas: String
    let rivals: String
    let rockets: String
    let bulletCasings: String
    let clothSupplies: String
    let woodSupplies: String
    let metalSupplies: String
    let techSupplies: String
    let medicalSupplies: String
    let armor: String
    let unshakableResolveUses: String
    let mysteriousStrangerUses: String
    let playerId: Int
    let characterTypeId: Int
    var skills: [OldFullSkillModel]

    init(id: Int, fullName: String, startDate: String, isAlive: String, deathDate: String, infection: String, bio: String, approvedBio: String, bullets: String, megas: String, rivals: String, rockets: String, bulletCasings: String, clothSupplies: String, woodSupplies: String, metalSupplies: String, techSupplies: String, medicalSupplies: String, armor: String, unshakableResolveUses: String, mysteriousStrangerUses: String, playerId: Int, characterTypeId: Int, skills: [OldFullSkillModel]) {
        self.id = id
        self.fullName = fullName
        self.startDate = startDate
        self.isAlive = isAlive
        self.deathDate = deathDate
        self.infection = infection
        self.bio = bio
        self.approvedBio = approvedBio
        self.bullets = bullets
        self.megas = megas
        self.rivals = rivals
        self.rockets = rockets
        self.bulletCasings = bulletCasings
        self.clothSupplies = clothSupplies
        self.woodSupplies = woodSupplies
        self.metalSupplies = metalSupplies
        self.techSupplies = techSupplies
        self.medicalSupplies = medicalSupplies
        self.armor = armor
        self.unshakableResolveUses = unshakableResolveUses
        self.mysteriousStrangerUses = mysteriousStrangerUses
        self.playerId = playerId
        self.characterTypeId = characterTypeId
        self.skills = skills
    }

    init(_ charModel: CharacterModel) {
        self.id = charModel.id
        self.fullName = charModel.fullName
        self.startDate = charModel.startDate
        self.isAlive = charModel.isAlive
        self.deathDate = charModel.deathDate
        self.infection = charModel.infection
        self.bio = charModel.bio
        self.approvedBio = charModel.approvedBio
        self.bullets = charModel.bullets
        self.megas = charModel.megas
        self.rivals = charModel.rivals
        self.rockets = charModel.rockets
        self.bulletCasings = charModel.bulletCasings
        self.clothSupplies = charModel.clothSupplies
        self.woodSupplies = charModel.woodSupplies
        self.metalSupplies = charModel.metalSupplies
        self.techSupplies = charModel.techSupplies
        self.medicalSupplies = charModel.medicalSupplies
        self.playerId = charModel.playerId
        self.armor = charModel.armor
        self.unshakableResolveUses = charModel.unshakableResolveUses
        self.mysteriousStrangerUses = charModel.mysteriousStrangerUses
        self.characterTypeId = charModel.characterTypeId
        self.skills = []
    }

    var baseModel: CharacterModel {
        CharacterModel(self)
    }

    var barcodeModel: CharacterBarcodeModel {
        return CharacterBarcodeModel(self)
    }

    func getIntrigueSkills() -> [Int] {
        var intrigueSkills = [Int]()
        let filteredSkills = skills.filter { sk in
            return sk.id.equalsAnyOf(Constants.SpecificSkillIds.investigatorTypeSkills)
        }
        for fs in filteredSkills {
            intrigueSkills.append(fs.id)
        }
        return intrigueSkills
    }

    func getChooseOneSkills() -> [OldFullSkillModel] {
        return skills.filter { skill in
            return skill.id.equalsAnyOf(Constants.SpecificSkillIds.allSpecalistSkills)
        }
    }

    func costOfCombatSkills() -> Int {
        for skill in skills {
            if skill.id.equalsAnyOf(Constants.SpecificSkillIds.allCombatReducingSkills) {
                return -1
            }
            if skill.id.equalsAnyOf(Constants.SpecificSkillIds.allCombatIncreasingSkills) {
                return 1
            }
        }
        return 0
    }

    func costOfProfessionSkills() -> Int {
        for skill in skills {
            if skill.id.equalsAnyOf(Constants.SpecificSkillIds.allProfessionReducingSkills) {
                return -1
            }
            if skill.id.equalsAnyOf(Constants.SpecificSkillIds.allProfessionIncreasingSkills) {
                return 1
            }
        }
        return 0
    }

    func costOfTalentSkills() -> Int {
        for skill in skills {
            if skill.id.equalsAnyOf(Constants.SpecificSkillIds.allTalentReducingSkills) {
                return -1
            }
            if skill.id.equalsAnyOf(Constants.SpecificSkillIds.allTalentIncreasingSkills) {
                return 1
            }
        }
        return 0
    }

    func costOf50InfectSkills() -> Int {
        for skill in skills {
            guard skill.id == Constants.SpecificSkillIds.adaptable else { continue }
            return 25
        }
        return 50
    }

    func costOf75InfectSkills() -> Int {
        for skill in skills {
            guard skill.id == Constants.SpecificSkillIds.extremelyAdaptable else { continue }
            return 50
        }
        return 75
    }

    func getRelevantBarcodeSkills() -> [SkillBarcodeModel] {
        var barSkills = [SkillBarcodeModel]()
        for skill in skills {
            guard skill.id.equalsAnyOf(Constants.SpecificSkillIds.barcodeRelevantSkills) else { continue }
            barSkills.append(skill.barcodeModel)
        }
        return barSkills
    }

}

struct CharacterBarcodeModel: CustomCodeable {
    let id: Int
    let fullName: String
    let infection: String
    let bullets: String
    let megas: String
    let rivals: String
    let rockets: String
    let bulletCasings: String
    let clothSupplies: String
    let woodSupplies: String
    let metalSupplies: String
    let techSupplies: String
    let medicalSupplies: String
    let armor: String
    let unshakableResolveUses: String
    let mysteriousStrangerUses: String
    let playerId: Int

    init(_ characterModel: OldFullCharacterModel) {
        self.id = characterModel.id
        self.fullName = characterModel.fullName
        self.infection = characterModel.infection
        self.bullets = characterModel.bullets
        self.megas = characterModel.megas
        self.rivals = characterModel.rivals
        self.rockets = characterModel.rockets
        self.bulletCasings = characterModel.bulletCasings
        self.clothSupplies = characterModel.clothSupplies
        self.woodSupplies = characterModel.woodSupplies
        self.metalSupplies = characterModel.metalSupplies
        self.techSupplies = characterModel.techSupplies
        self.medicalSupplies = characterModel.medicalSupplies
        self.armor = characterModel.armor
        self.unshakableResolveUses = characterModel.unshakableResolveUses
        self.mysteriousStrangerUses = characterModel.mysteriousStrangerUses
        self.playerId = characterModel.playerId
    }
}

struct CharacterModel: CustomCodeable, Identifiable {
    let id: Int
    let fullName: String
    let startDate: String
    var isAlive: String
    let deathDate: String
    var infection: String
    var bio: String
    var approvedBio: String
    var bullets: String
    let megas: String
    let rivals: String
    let rockets: String
    let bulletCasings: String
    let clothSupplies: String
    let woodSupplies: String
    let metalSupplies: String
    let techSupplies: String
    let medicalSupplies: String
    let armor: String
    let unshakableResolveUses: String
    let mysteriousStrangerUses: String
    let playerId: Int
    let characterTypeId: Int

    enum ArmorType: String {
        case none = "None"
        case metal = "Metal Armor"
        case bulletProof = "Bullet Proof"
    }
    
    init(_ char: FullCharacterModel) {
        self.id = char.id
        self.fullName = char.fullName
        self.startDate = char.startDate
        self.isAlive = char.isAlive.stringValue
        self.deathDate = char.deathDate
        self.infection = char.infection.stringValue
        self.bio = char.bio
        self.approvedBio = char.approvedBio.stringValue
        self.bullets = char.bullets.stringValue
        self.megas = char.megas.stringValue
        self.rivals = char.rivals.stringValue
        self.rockets = char.rockets.stringValue
        self.bulletCasings = char.bulletCasings.stringValue
        self.clothSupplies = char.clothSupplies.stringValue
        self.woodSupplies = char.woodSupplies.stringValue
        self.metalSupplies = char.metalSupplies.stringValue
        self.techSupplies = char.techSupplies.stringValue
        self.medicalSupplies = char.medicalSupplies.stringValue
        self.armor = char.armor
        self.unshakableResolveUses = char.unshakableResolveUses.stringValue
        self.mysteriousStrangerUses = char.mysteriousStrangerUses.stringValue
        self.playerId = char.playerId
        self.characterTypeId = char.characterTypeId
    }


    init(id: Int, fullName: String, startDate: String, isAlive: String, deathDate: String, infection: String, bio: String, approvedBio: String, bullets: String, megas: String, rivals: String, rockets: String, bulletCasings: String, clothSupplies: String, woodSupplies: String, metalSupplies: String, techSupplies: String, medicalSupplies: String, armor: String, unshakableResolveUses: String, mysteriousStrangerUses: String, playerId: Int, characterTypeId: Int) {
        self.id = id
        self.fullName = fullName
        self.startDate = startDate
        self.isAlive = isAlive
        self.deathDate = deathDate
        self.infection = infection
        self.bio = bio
        self.approvedBio = approvedBio
        self.bullets = bullets
        self.megas = megas
        self.rivals = rivals
        self.rockets = rockets
        self.bulletCasings = bulletCasings
        self.clothSupplies = clothSupplies
        self.woodSupplies = woodSupplies
        self.metalSupplies = metalSupplies
        self.techSupplies = techSupplies
        self.medicalSupplies = medicalSupplies
        self.armor = armor
        self.unshakableResolveUses = unshakableResolveUses
        self.mysteriousStrangerUses = mysteriousStrangerUses
        self.playerId = playerId
        self.characterTypeId = characterTypeId
    }
    
    var subModel: CharacterSubModel {
        return CharacterSubModel(id: self.id, isAlive: self.isAlive)
    }

    func getAllXpSpent(onSuccess: @escaping (_ xp: Int) -> Void, failureCase: @escaping FailureCase) {
        CharacterSkillService.getAllSkillsForChar(self.id, onSuccess: { charSkills in
            var cost = 0
            for skill in charSkills.charSkills {
                cost += skill.xpSpent
            }
            onSuccess(cost)
        }, failureCase: failureCase)

    }

    func getAllSpentPrestige(onSuccess: @escaping (_ pp: Int) -> Void, failureCase: @escaping FailureCase) {
        CharacterSkillService.getAllSkillsForChar(self.id, onSuccess: { charSkills in
            var cost = 0
            for skill in charSkills.charSkills {
                cost += skill.ppSpent
            }
            onSuccess(cost)
        }, failureCase: failureCase)

    }
}

struct CreateCharacterModel: CustomCodeable {
    let fullName: String
    let startDate: String
    let isAlive: String
    let deathDate: String
    let infection: String
    let bio: String
    let approvedBio: String
    let bullets: String
    let megas: String
    let rivals: String
    let rockets: String
    let bulletCasings: String
    let clothSupplies: String
    let woodSupplies: String
    let metalSupplies: String
    let techSupplies: String
    let medicalSupplies: String
    let armor: String
    let unshakableResolveUses: String
    let mysteriousStrangerUses: String
    let playerId: Int
    let characterTypeId: Int
}

struct CharacterSubModel: CustomCodeable {
    let id: Int
    let isAlive: String
}

struct CharacterListModel: CustomCodeable {
    var characters: [CharacterSubModel]
}

struct CharacterListFullModel: CustomCodeable {
    var characters: [CharacterModel]
}
