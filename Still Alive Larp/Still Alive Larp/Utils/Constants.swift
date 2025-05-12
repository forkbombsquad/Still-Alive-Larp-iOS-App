//
//  Constants.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/14/23.
//

import Foundation

struct Constants {
    
    struct Logging {
//        TODO ALWAYS - set these to false before release
        static let showServiceLogging = true
        static let showTestLogging = true
        static let showDebugButtonInAccountView = true
        static let allowChangingServiceOperationMode = true
    }
    
    struct ServiceOperationMode {
        // TODO ALWAYS - set this to prod before release
        static private(set) var serviceMode: ServiceEndpoints.ServiceMode = .prod
        
        static func updateServiceMode(_ newMode: ServiceEndpoints.ServiceMode) {
            if Logging.allowChangingServiceOperationMode {
                serviceMode = newMode
            }
        }
    }
    
    struct CharacterTypes {
        static let standard = 1
        static let NPC = 2
        static let planner = 3
        static let hidden = 4
    }

    struct Notifications {
        static let refreshHomescreen = NSNotification.Name("Refresh Homescreen")
    }

    struct urls {
        static let skillTreeImage = "https://stillalivelarp.com/skilltree"
        static let skillTreeImageDark = "https://stillalivelarp.com/skilltree/dark"
        static let treatingWoundsImage = "https://stillalivelarp.com/healing"
        static let rulebook = "https://stillalivelarp.com/rulebook-app"
    }

    struct SkillTypes {
        static let combat = 1
        static let profession = 2
        static let talent = 3
    }

    struct SpecificSkillIds {
        static let combatAficionado_T = 11
        static let combatSpecialist_P = 12
        static let expertCombat = 19
        static let professionAficionado_T = 63
        static let professionSpecialist_C = 64
        static let expertProfession = 20
        static let talentAficionado_C = 74
        static let talentSpecialist_P = 75
        static let expertTalent = 21

        // Adaptable Type
        static let adaptable = 1
        static let extremelyAdaptable = 23

        // Deep Pockets Type
        static let bandoliers = 5
        static let parachutePants = 61
        static let deeperPockets = 16
        static let deepPockets = 15

        // Investigator Type
        static let investigator = 38
        static let interrogator = 37
        static let webOfInformants = 92

        // Tough Skin Type
        static let toughSkin = 80
        static let painTolerance = 60
        static let naturalArmor = 55
        static let scaledSkin = 70

        // Walk like a zombie type
        static let deadManStanding = 13
        static let deadManWalking = 14

        // Gambler type
        static let gamblersLuck = 29
        static let gamblersTalent = 30
        static let gamblersEye = 27
        static let gamblersHeart = 28

        // Regression type
        static let regression = 68
        static let remission = 69

        // Will to live type
        static let willToLive = 93
        static let unshakableResolve = 89

        // Mysterious Stranger type
        static let mysteriousStranger = 54
        static let unknownAssailant = 88
        static let annonomousAlly = 4

        // Plot Armor Type
        static let plotArmor = 96

        // Fully Loaded Type
        static let fullyLoaded = 100

        // Fortune Skills
        static let fortunateFind = 97
        static let prosperousDiscovery = 98

        static let allSpecalistSkills = [combatAficionado_T, combatSpecialist_P, expertCombat, professionAficionado_T, professionSpecialist_C, expertProfession, talentAficionado_C, talentSpecialist_P, expertTalent]

        static let allLevel2SpecialistSkills = [combatAficionado_T, combatSpecialist_P, professionAficionado_T, professionSpecialist_C, talentAficionado_C, talentSpecialist_P]

        static let allSpecalistsNotUnderExpertCombat = [combatSpecialist_P, professionSpecialist_C, talentAficionado_C, combatAficionado_T, expertTalent, expertProfession]
        static let allSpecalistsNotUnderExpertProfession = [professionSpecialist_C, professionAficionado_T, combatSpecialist_P, talentSpecialist_P, expertCombat, expertTalent]
        static let allSpecalistsNotUnderExpertTalent = [talentSpecialist_P, talentAficionado_C, professionAficionado_T, combatAficionado_T, expertCombat, expertProfession]

        static let allCombatReducingSkills = [combatAficionado_T, combatSpecialist_P, expertCombat]
        static let allCombatIncreasingSkills = [professionSpecialist_C, talentAficionado_C]
        static let allProfessionReducingSkills = [professionSpecialist_C, professionAficionado_T, expertProfession]
        static let allProfessionIncreasingSkills = [combatSpecialist_P, talentSpecialist_P]
        static let allTalentReducingSkills = [talentSpecialist_P, talentAficionado_C, expertTalent]
        static let allTalentIncreasingSkills = [combatAficionado_T, professionAficionado_T]

        static let barcodeRelevantSkills: [Int] = deepPocketTypeSkills + investigatorTypeSkills + toughSkinTypeSkills + walkLikeAZombieTypeSkills + gamblerTypeSkills + regressionTypeSkills + willToLiveTypeSkills + mysteriousStrangerTypeSkills + fortuneSkills + [fullyLoaded]

        static let deepPocketTypeSkills: [Int] = [bandoliers, parachutePants, deeperPockets, deepPockets]
        static let investigatorTypeSkills: [Int] = [investigator, interrogator, webOfInformants]
        static let toughSkinTypeSkills: [Int] = [toughSkin, painTolerance, naturalArmor, scaledSkin, plotArmor]
        static let walkLikeAZombieTypeSkills: [Int] = [deadManStanding, deadManWalking]
        static let gamblerTypeSkills: [Int] = [gamblersLuck, gamblersTalent, gamblersEye, gamblersHeart]
        static let regressionTypeSkills = [regression, remission]
        static let willToLiveTypeSkills = [willToLive, unshakableResolve]
        static let mysteriousStrangerTypeSkills = [mysteriousStranger, unknownAssailant, annonomousAlly]

        static let fortuneSkills = [fortunateFind, prosperousDiscovery]

        static let checkInRelevantSkillsOnly = deepPocketTypeSkills + toughSkinTypeSkills + walkLikeAZombieTypeSkills + investigatorTypeSkills + gamblerTypeSkills + fortuneSkills + [fullyLoaded]

    }
    
    struct GearTypes {
        static let meleeWeapon = "Melee Weapon"
        static let firearm = "Firearm"
        static let clothing = "Clothing"
        static let accessory = "Accessory"
        static let bag = "Bag"
        static let other = "Other"

        static let allTypes = [meleeWeapon, firearm, clothing, accessory, bag, other]
    }

    struct GearPrimarySubtype {
        static let superLightMeleeWeapon = "Super Light Melee Weapon"
        static let lightMeleeWeapon = "Light Melee Weapon"
        static let mediumMeleeWeapon = "Medium Melee Weapon"
        static let heavyMeleeWeapon = "Heavy Melee Weapon"

        static let lightFirearm = "Light Firearm"
        static let mediumFirearm = "Medium Firearm"
        static let heavyFirearm = "Heavy Firearm"
        static let advancedFirearm = "Advanced Firearm"
        static let militaryGradeFirearm = "Military Grade Firearm"

        static let blacklightFlashlight = "Blacklight Flashlight"
        static let flashlight = "Regular Flashlight"

        static let smallBag = "Small Bag"
        static let mediumBag = "Medium Bag"
        static let largeBag = "Large Bag"
        static let extraLargeBag = "Extra Large Bag"

        static let other = "Other"
        static let none = "None"

        static let allMeleeTypes = [superLightMeleeWeapon, lightMeleeWeapon, mediumMeleeWeapon, heavyMeleeWeapon]
        static let allFirearmTypes = [lightFirearm, mediumFirearm, heavyFirearm, advancedFirearm, militaryGradeFirearm]
        static let allClothingTypes = [none]
        static let allAccessoryTypes = [blacklightFlashlight, flashlight, other]
        static let allBagTypes = [smallBag, mediumBag, largeBag, extraLargeBag]
        static let allOtherTypes = [other]
    }

    struct GearSecondarySubtype {
        static let none = "None"
        static let primaryFirearm = "Primary Firearm"

        static let allFirearmTypes = [none, primaryFirearm]
        static let allNonFirearmTypes = [none]
    }

}
