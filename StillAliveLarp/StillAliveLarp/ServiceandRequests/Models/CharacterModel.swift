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
                                                combatXpMod: FullCharacterModel.costOfCombatSkills(pskills),
                                                professionXpMod: FullCharacterModel.costOfProfessionSkills(pskills),
                                                talentXpMod: FullCharacterModel.costOfTalentSkills(pskills),
                                                inf50Mod: FullCharacterModel.costOf50InfectSkills(pskills),
                                                inf75Mod: FullCharacterModel.costOf75InfectSkills(pskills)
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
        if allPurchaseableSkills().first(where: { $0.id == skill.id }) != nil {
            // Skill Could be purchased
            askToPurchase(skill: skill) { cscm in
                if let charSkillCreateModel = cscm {
                    switch characterType() {
                    case .standard:
                        // Standard chars
                        CharacterSkillService.takeSkill(charSkillCreateModel, playerId: playerId) {
                            _ in
                            AlertManager.shared.showOkAlert("Skill Successfully Purchased!", message: "\(fullName) now possesses the skill \(skill.name).") {
                                completion(true)
                            }
                        } failureCase: { error in
                            completion(false)
                        }

                    case .npc, .planner:
                        CharacterSkillService.takePlannedCharacterSkill(charSkillCreateModel) { _ in
                            AlertManager.shared.showOkAlert("Skill Successfully \(characterType() == .planner ? "Planned!" : "Added To NPC!")", message: "\(fullName) now possesses the skill \(skill.name)") {
                                completion(true)
                            }
                        } failureCase: { error in
                            completion(false)
                        }

                    case .hidden:
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            }
        } else {
            // Skill cannot be purchased
            completion(false)
        }
    }
    
    private func askToPurchase(skill: FullCharacterModifiedSkillModel, completion: @escaping (_ cscm: CharacterSkillCreateModel?) -> Void) {
        var freeSkillPrompt = ""
        var purchaseTitle = ""
        var purchaseText = ""
        switch characterType() {
        case .standard:
            freeSkillPrompt = "Use 1 Free Tier-1 Skill?"
            purchaseText = "Purchase \(skill.name)?"
            purchaseTitle = "Confirm Purchase?"
        case .npc:
            freeSkillPrompt = "Use NPC 1 Free Tier-1 Skill?"
            purchaseText = "Purchase \(skill.name) For NPC?"
            purchaseTitle = "Confirm NPC Purchase?"
        case .planner:
            freeSkillPrompt = "Plan to use 1 Free Tier-1 Skill?"
            purchaseText = "Plan to purchase \(skill.name)?"
            purchaseTitle = "Confirm Planned Purchase?"
        case .hidden:
            completion(nil)
            return
        }
        if skill.canUseFreeSkill() {
            promptTOUseFt1s(title: freeSkillPrompt) { useFt1s in
                promptToPurchase(title: purchaseTitle, purchaseText: purchaseText, useFreeSkill: useFt1s, skill: skill, completion: completion)
            }
        } else {
            promptToPurchase(title: purchaseTitle, purchaseText: purchaseText, useFreeSkill: false, skill: skill, completion: completion)
        }
    }
    
    private func promptTOUseFt1s(title: String, completion: @escaping (_ useFt1s: Bool) -> Void) {
        AlertManager.shared.showDynamicAlert(model: CustomAlertModel(title: title, textFields: [], checkboxes: [], verticalButtons: [], buttons: [AlertButton(title: "Use Xp", onPress: {
            completion(false)
        }), AlertButton(title: "Use Free Tier-1 Skill", onPress: {
            completion(true)
        })]))
    }
    
    private func promptToPurchase(title: String, purchaseText: String, useFreeSkill: Bool, skill: FullCharacterModifiedSkillModel, completion: @escaping (_ charSkill: CharacterSkillCreateModel?) -> Void) {
        var message = "\(purchaseText) using:\n"
        message += "\(useFreeSkill ? "1 Free Tier-1 Skill Point" : "\(skill.modXpCost()) Experience Point\(skill.modXpCost().pluralizeString)")"
        
        if skill.usesPrestige() {
            message += " and \(skill.prestigeCost()) Prestige Point"
        }
        message += "?"
        
        AlertManager.shared.showOkCancelAlert(title, message: message) {
            completion(
                CharacterSkillCreateModel(characterId: id, skillId: skill.id, xpSpent: useFreeSkill ? 0 : skill.modXpCost(), fsSpent: useFreeSkill ? 1 : 0, ppSpent: skill.prestigeCost())
            )
        } onCancelAction: {
            completion(nil)
        }
    }
    
    func allPurchaseableSkills(searchText: String = "", filter: SkillFilterType = .none) -> [FullCharacterModifiedSkillModel] {
        let charSkills = allNonPurchasedSkills()
        let player = DataManager.shared.getPlayerForCharacter(self)
        
        // Remove all skills you don't have prereqs for
        var newSkillList = charSkills.filter { skillToKeep in
            hasAllPrereqsForSkill(skill: skillToKeep)
        }
        
        // Planned and NPC charactesr don't require prestige points
        if characterType() != .planner && characterType() != .npc {
            newSkillList = newSkillList.filter { skillToKeep in
                skillToKeep.prestigeCost() <= player.prestigePoints
            }
        }
        
        // Remove choose one skills that can't be chosen
        let cskills = getPurchasedChooseOneSkills()
        if cskills.isEmpty {
            // Has none
            // Remove all level 2 cskills is they don't have a level 1
            newSkillList = newSkillList.filter { skillToKeep in
                !skillToKeep.id.equalsAnyOf(Constants.SpecificSkillIds.allLevel2SpecialistSkills)
            }
        } else if cskills.count == 2 {
            // Has 2
            // Remove all cskills if a character already has 2
            newSkillList = newSkillList.filter({ skillToKeep in
                !skillToKeep.id.equalsAnyOf(Constants.SpecificSkillIds.allSpecalistSkills)
            })
        } else if cskills.count == 1 {
            // Has 1
            // Remoe only the non relevant ones
            var idsToRemove = [Int]()
            switch cskills.first?.id ?? 0 {
            case Constants.SpecificSkillIds.expertCombat:
                idsToRemove = Constants.SpecificSkillIds.allSpecalistsNotUnderExpertCombat
            case Constants.SpecificSkillIds.expertTalent:
                idsToRemove = Constants.SpecificSkillIds.allSpecalistsNotUnderExpertTalent
            case Constants.SpecificSkillIds.expertProfession:
                idsToRemove = Constants.SpecificSkillIds.allSpecalistsNotUnderExpertProfession
            default:
                break
            }
            
            // Remove the cskills in the list to remove
            newSkillList = newSkillList.filter({ skillToKeep in
                !skillToKeep.id.equalsAnyOf(idsToRemove)
            })
        }
        
        // Planned and NPC characters don't requrie xp, free skills, or infection
        if characterType() != .npc && characterType() != .planner {
            // Filter out skills you don't have enough xp, fs or int for
            newSkillList = newSkillList.filter { skillToKeep in
                var keep = true
                if infection < skillToKeep.modInfectionCost() {
                    keep = false
                }
                if keep {
                    if skillToKeep.canUseFreeSkill() && player.freeTier1Skills > 0 {
                        keep = true
                    } else if player.experience >= skillToKeep.modXpCost() {
                        keep = true
                    } else {
                        keep = false
                    }
                }
                return keep
            }
        }
        
        return newSkillList.filter { skillToKeep in
            skillToKeep.includeInFilter(searchText: searchText, filterType: filter)
        }
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
    
    func getPurchasedIntrigueSkills() -> [Int] {
        return allPurchasedSkills().filter { sk in
            sk.id.equalsAnyOf(Constants.SpecificSkillIds.investigatorTypeSkills)
        }.map { $0.id }
    }
    
    func getPurchasedChooseOneSkills() -> [FullCharacterModifiedSkillModel] {
        return allPurchasedSkills().filter { skill in
            skill.id.equalsAnyOf(Constants.SpecificSkillIds.allSpecalistSkills)
        }
    }
    
    private static func costOfCombatSkills(_ purchasedSkills: [FullSkillModel]) -> Int {
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
    
    private static func costOfProfessionSkills(_ purchasedSkills: [FullSkillModel]) -> Int {
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
    
    private static func costOfTalentSkills(_ purchasedSkills: [FullSkillModel]) -> Int {
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
    
    private static func costOf50InfectSkills(_ purchasedSkills: [FullSkillModel]) -> Int {
        return purchasedSkills.first(where: { $0.id == Constants.SpecificSkillIds.adaptable }) != nil ? 25 : 50
    }
    
    private static func costOf75InfectSkills(_ purchasedSkills: [FullSkillModel]) -> Int {
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
    
    func getPurchasedSkillsFiltered(searchText: String, filter: SkillFilterType) -> [FullCharacterModifiedSkillModel] {
        return allPurchasedSkills().filter({ $0.includeInFilter(searchText: searchText, filterType: filter) })
    }
    
    func getAwardsSorted() -> [AwardModel] {
        let sortedAwards = awards.sorted {
            return $0.date.yyyyMMddtoDate() > $1.date.yyyyMMddtoDate() // descending
        }
        return sortedAwards
    }
    
    func deleteSkillsDESTRUCTIVE(completion: @escaping (_ success: Bool) -> Void) {
        CharacterSkillService.deleteSkills(characterId: id) { _ in
            completion(true)
        } failureCase: { error in
            completion(false)
        }

    }
    
    func deleteCharacterDESTRUCTIVE(completion: @escaping (_ success: Bool) -> Void) {
        CharacterService.deleteCharacter(id: id) { _ in
            completion(true)
        } failureCase: { error in
            completion(false)
        }
    }
    
    func getAllXpSpent() -> Int {
        return allPurchasedSkills().sumOf({ $0.spentXp() })
    }
    
    func getAllSpentPrestigePoints() -> Int {
        return allPurchasedSkills().sumOf({ $0.spentPp() })
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
