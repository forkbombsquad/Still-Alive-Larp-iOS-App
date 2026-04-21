//
//  PlayerModelTests.swift
//  Still Alive LarpTests
//
//  Tests for PlayerModel functionality
//

import XCTest
@testable import StillAliveLarp

class PlayerModelTests: BaseTestClass {

    func testPlayerBasicFields() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        XCTAssertNotNil(player)
        
        XCTAssertEqual(player?.id, 1)
        XCTAssertEqual(player?.username, "test@test.test")
        XCTAssertEqual(player?.fullName, "Test Testerson")
    }

    func testGetActiveCharacter() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        XCTAssertNotNil(player)
        
        let activeChar = player?.getActiveCharacter()
        XCTAssertNotNil(activeChar)
        XCTAssertEqual(activeChar?.id, 1)
        XCTAssertEqual(activeChar?.fullName, "John Doe")
    }

    func testCharacterGroups() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        XCTAssertNotNil(player)
        
        let inactiveChars = player?.getInactiveCharacters() ?? []
        XCTAssertTrue(inactiveChars.isEmpty)
        
        let plannedChars = player?.getPlannedCharacters() ?? []
        XCTAssertTrue(plannedChars.isEmpty)
    }

    func testCheckInBarcodeModelWithCharacter() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let event = DataManager.shared.events.first
        XCTAssertNotNil(player)
        XCTAssertNotNil(event)
        
        let barcode = player?.getCheckInBarcodeModel(useChar: true, event: event!)
        XCTAssertNotNil(barcode)
        
        XCTAssertEqual(barcode?.playerId, 1)
        XCTAssertEqual(barcode?.characterId, 1)
        XCTAssertEqual(barcode?.eventId, 1)
    }

    func testCheckInBarcodeModelWithoutCharacter() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let event = DataManager.shared.events.first
        XCTAssertNotNil(player)
        XCTAssertNotNil(event)
        
        let barcode = player?.getCheckInBarcodeModel(useChar: false, event: event!)
        XCTAssertNotNil(barcode)
        
        XCTAssertEqual(barcode?.playerId, 1)
        XCTAssertNil(barcode?.characterId)
        XCTAssertEqual(barcode?.eventId, 1)
    }

    func testCheckOutBarcodeModelWithCharacter() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let attendee = EventAttendeeModel(id: 1, playerId: 1, characterId: 1, eventId: 1, isCheckedIn: "TRUE", asNpc: "FALSE", npcId: -1)
        XCTAssertNotNil(player)
        
        let barcode = player?.getCheckOutBarcodeModel(eventAttendee: attendee)
        XCTAssertNotNil(barcode)
        
        XCTAssertEqual(barcode?.playerId, 1)
        XCTAssertEqual(barcode?.characterId, 1)
        XCTAssertEqual(barcode?.eventId, 1)
    }

    func testCheckOutBarcodeModelAsNPC() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        let attendee = EventAttendeeModel(id: 1, playerId: 1, characterId: nil, eventId: 1, isCheckedIn: "TRUE", asNpc: "TRUE", npcId: 1)
        XCTAssertNotNil(player)
        
        let barcode = player?.getCheckOutBarcodeModel(eventAttendee: attendee)
        XCTAssertNotNil(barcode)
        
        XCTAssertEqual(barcode?.playerId, 1)
        XCTAssertNil(barcode?.characterId)
        XCTAssertEqual(barcode?.eventId, 1)
    }

    func testPlayerStats() async throws {
        await loadDataManager {}
        let player = DataManager.shared.getCurrentPlayer()
        XCTAssertNotNil(player)
        
        let xp = player?.experience
        XCTAssertTrue(xp ?? 0 >= 0)
        
        let pp = player?.prestigePoints
        XCTAssertTrue(pp ?? 0 >= 0)
        
        let events = player?.numEventsAttended ?? 0
        XCTAssertTrue(events >= 0)
    }
}
