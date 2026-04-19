//
//  CharacterModelTests.swift
//  Still Alive LarpTests
//
//  Tests for CharacterModel functionality
//

import XCTest
@testable import StillAliveLarp

class CharacterModelTests: BaseTestClass {

    func testCharacterExists() async throws {
        await loadDataManager {}
        let players = DataManager.shared.players
        XCTAssertFalse(players.isEmpty)
        
        let player = players.first
        XCTAssertNotNil(player)
        
        let characters = player?.characters ?? []
        XCTAssertFalse(characters.isEmpty)
    }

    func testCharacterFields() async throws {
        await loadDataManager {}
        let player = DataManager.shared.players.first
        let char = player?.characters.first
        XCTAssertNotNil(char)
        
        XCTAssertEqual(char?.id, 1)
        XCTAssertFalse(char?.fullName.isEmpty ?? true)
    }

    func testCharacterStats() async throws {
        await loadDataManager {}
        let player = DataManager.shared.players.first
        let char = player?.characters.first
        XCTAssertNotNil(char)
        
        let bullets = char?.bullets
        XCTAssertTrue(bullets ?? 0 >= 0)
    }
}