//
//  PlayerModelTests.swift
//  Still Alive LarpTests
//
//  Tests for PlayerModel functionality
//

import XCTest
@testable import StillAliveLarp

class PlayerModelTests: BaseTestClass {

    func testPlayerExists() async throws {
        await loadDataManager {}
        let players = DataManager.shared.players
        XCTAssertFalse(players.isEmpty)
    }

    func testPlayerFields() async throws {
        await loadDataManager {}
        let player = DataManager.shared.players.first
        XCTAssertNotNil(player)
        
        XCTAssertEqual(player?.id, 1)
        XCTAssertFalse(player?.username.isEmpty ?? true)
        XCTAssertFalse(player?.fullName.isEmpty ?? true)
    }
}