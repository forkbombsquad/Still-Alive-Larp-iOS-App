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
        XCTAssertEqual(char1?.fullName, "John Doe")
        XCTAssertEqual(char1?.startDate, "2022/12/23")
        XCTAssertTrue(char1?.isAlive ?? false)
        XCTAssertEqual(char1?.deathDate, "")
        XCTAssertEqual(char1?.infection, 10)
    }

    func testCharacterStatsFields() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let char1 = player?.characters.first { $0.id == 1 }
        XCTAssertNotNil(char1)
        
        XCTAssertEqual(char1?.bullets, 10)
        XCTAssertEqual(char1?.megas, 1)
        XCTAssertEqual(char1?.rivals, 5)
        XCTAssertEqual(char1?.rockets, 2)
        XCTAssertEqual(char1?.bulletCasings, 54)
    }

    func testCharacterSuppliesFields() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let char1 = player?.characters.first { $0.id == 1 }
        XCTAssertNotNil(char1)
        
        XCTAssertEqual(char1?.clothSupplies, 6)
        XCTAssertEqual(char1?.woodSupplies, 4)
        XCTAssertEqual(char1?.metalSupplies, 2)
        XCTAssertEqual(char1?.techSupplies, 8)
        XCTAssertEqual(char1?.medicalSupplies, 11)
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
    
    func testCharacterSkills() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let char1 = player?.characters.first { $0.id == 1 }
        XCTAssertNotNil(char1)
        
        let skills = char1?.allPurchasedSkills() ?? []
        XCTAssertTrue(skills.count >= 2)
    }

    func testStringConversions() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let char1 = player?.characters.first { $0.id == 1 }
        XCTAssertNotNil(char1)
        
        let bullets = char1?.bullets
        XCTAssertEqual(bullets, 10)

        let megas = char1?.megas
        XCTAssertEqual(megas, 1)
    }

    func testCharacterType() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let char1 = player?.characters.first { $0.id == 1 }
        XCTAssertNotNil(char1)
        
        let characterType = char1?.characterTypeId
        XCTAssertEqual(characterType, 1)
    }
}
