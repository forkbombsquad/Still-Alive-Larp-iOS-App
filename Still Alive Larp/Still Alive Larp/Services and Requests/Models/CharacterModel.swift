//
//  CharacterModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/11/22.
//

import Foundation

struct FullCharacterModel: CustomCodeable {
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
    var skills: [FullSkillModel]

    init(id: Int, fullName: String, startDate: String, isAlive: String, deathDate: String, infection: String, bio: String, approvedBio: String, bullets: String, megas: String, rivals: String, rockets: String, bulletCasings: String, clothSupplies: String, woodSupplies: String, metalSupplies: String, techSupplies: String, medicalSupplies: String, armor: String, unshakableResolveUses: String, mysteriousStrangerUses: String, playerId: Int, characterTypeId: Int, skills: [FullSkillModel]) {
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

    func getChooseOneSkills() -> [FullSkillModel] {
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
    let characterTypeId: Int

    init(_ characterModel: FullCharacterModel) {
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
        self.unshakableResolveUses = characterModel.mysteriousStrangerUses
        self.mysteriousStrangerUses = characterModel.mysteriousStrangerUses
        self.playerId = characterModel.playerId
        self.characterTypeId = characterModel.characterTypeId
    }
}

struct CharacterModel: CustomCodeable, Identifiable {
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

    enum ArmorType: String {
        case none = "None"
        case metal = "Metal Armor"
        case bulletProof = "Bullet Proof"
    }

    init(_ char: FullCharacterModel) {
        self.id = char.id
        self.fullName = char.fullName
        self.startDate = char.startDate
        self.isAlive = char.isAlive
        self.deathDate = char.deathDate
        self.infection = char.infection
        self.bio = char.bio
        self.approvedBio = char.approvedBio
        self.bullets = char.bullets
        self.megas = char.megas
        self.rivals = char.rivals
        self.rockets = char.rockets
        self.bulletCasings = char.bulletCasings
        self.clothSupplies = char.clothSupplies
        self.woodSupplies = char.woodSupplies
        self.metalSupplies = char.metalSupplies
        self.techSupplies = char.techSupplies
        self.medicalSupplies = char.medicalSupplies
        self.armor = char.armor
        self.unshakableResolveUses = char.unshakableResolveUses
        self.mysteriousStrangerUses = char.mysteriousStrangerUses
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
