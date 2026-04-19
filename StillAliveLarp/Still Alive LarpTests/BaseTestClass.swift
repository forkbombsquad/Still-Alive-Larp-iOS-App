//
//  BaseTestClass.swift
//  Still Alive LarpTests
//
//  Base test class for iOS unit tests
//

import XCTest
@testable import StillAliveLarp

class BaseTestClass: XCTestCase {

    override func setUp() {
        super.setUp()
        DataManager.shared.setDebugMode(true)
    }

    override func tearDown() {
        DataManager.shared.setDebugMode(false)
        super.tearDown()
    }

    func loadDataManager(mockDataLoaded: @escaping () -> Void) async {
        let expectation = self.expectation(description: "Data loaded")
        
        DataManager.shared.load(finished:  {
            mockDataLoaded()
            expectation.fulfill()
        })
        
        await fulfillment(of: [expectation], timeout: 10)
    }
}
