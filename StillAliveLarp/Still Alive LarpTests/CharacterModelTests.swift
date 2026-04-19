//
//  CharacterModelTests.swift
//  Still Alive LarpTests
//
//  Tests for CharacterModel functionality
//

import XCTest
@testable import StillAliveLarp

class CharacterModelTests: BaseTestClass {

    func testCharacterDirectFields() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        XCTAssertNotNil(player)
        
        let characters = player?.characters ?? []
        XCTAssertFalse(characters.isEmpty)

        let char1 = characters.first { $0.id == 1 }
        XCTAssertNotNil(char1)
        
        XCTAssertEqual(char1?.id, 1)
        XCTAssertEqual(char1?.fullName, "Commander Davis")
        XCTAssertEqual(char1?.startDate, "2023/06/03")
        XCTAssertTrue(char1?.isAlive ?? false)
        XCTAssertEqual(char1?.deathDate, "")
        XCTAssertEqual(char1?.infection, 0)
    }

    func testCharacterStatsFields() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let char1 = player?.characters.first { $0.id == 1 }
        XCTAssertNotNil(char1)
        
        XCTAssertEqual(char1?.bullets, 20)
        XCTAssertEqual(char1?.megas, 0)
        XCTAssertEqual(char1?.rivals, 0)
        XCTAssertEqual(char1?.rockets, 0)
        XCTAssertEqual(char1?.bulletCasings, 1)
    }

    func testCharacterSuppliesFields() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let char1 = player?.characters.first { $0.id == 1 }
        XCTAssertNotNil(char1)
        
        XCTAssertEqual(char1?.clothSupplies, 0)
        XCTAssertEqual(char1?.woodSupplies, 0)
        XCTAssertEqual(char1?.metalSupplies, 0)
        XCTAssertEqual(char1?.techSupplies, 0)
        XCTAssertEqual(char1?.medicalSupplies, 0)
    }

    func testCharacterOtherFields() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let char1 = player?.characters.first { $0.id == 1 }
        XCTAssertNotNil(char1)
        
        XCTAssertEqual(char1?.armor, "None")
        XCTAssertEqual(char1?.unshakableResolveUses, 0)
        XCTAssertEqual(char1?.mysteriousStrangerUses, 0)
        XCTAssertEqual(char1?.playerId, 1)
        XCTAssertEqual(char1?.characterTypeId, 1)
    }
    
    func testCharacterBioField() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let char1 = player?.characters.first { $0.id == 1 }
        XCTAssertNotNil(char1)
        
        XCTAssertFalse(char1?.bio.isEmpty ?? true)
    }

    func testCharacterSkills() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let char1 = player?.characters.first { $0.id == 1 }
        XCTAssertNotNil(char1)
        
        let skills = char1?.allPurchasedSkills() ?? []
        XCTAssertTrue(skills.count >= 2)
    }

    func testCharacterGear() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let char1 = player?.characters.first { $0.id == 1 }
        XCTAssertNotNil(char1)
        
        let gear = char1?.gear?.jsonModels ?? []
        XCTAssertFalse(gear.isEmpty)
    }

    func testCharacterXpReductions() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let char1 = player?.characters.first { $0.id == 1 }
        XCTAssertNotNil(char1)
        
        let xpReductions = char1?.xpReductions ?? []
        XCTAssertFalse(xpReductions.isEmpty)
    }

    func testCharacterAwards() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let char1 = player?.characters.first { $0.id == 1 }
        XCTAssertNotNil(char1)
        
        let awards = char1?.awards ?? []
        XCTAssertTrue(awards.isEmpty)
    }

    func testStringConversions() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let char1 = player?.characters.first { $0.id == 1 }
        XCTAssertNotNil(char1)
        
        let bullets = char1?.bullets
        XCTAssertEqual(bullets, 20)

        let megas = char1?.megas
        XCTAssertEqual(megas, 0)
    }

    func testCharacterType() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let char1 = player?.characters.first { $0.id == 1 }
        XCTAssertNotNil(char1)
        
        let characterType = char1?.characterTypeId
        XCTAssertEqual(characterType, 1)
    }

    func testOtherCharacters() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let characters = player?.characters ?? []
        
        let deadChar = characters.first { $0.isAlive == false }
        XCTAssertNotNil(deadChar)
        
        let plannedChar = characters.first { $0.characterType() == .planner }
        XCTAssertNil(plannedChar)
    }
}
