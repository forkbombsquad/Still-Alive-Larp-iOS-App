//
//  ExtensionTests.swift
//  Still Alive LarpTests
//
//  Tests for String, Int, Date extensions
//

import XCTest
@testable import StillAliveLarp

class ExtensionTests: BaseTestClass {

    func testStringCapitalize() {
        let str = "hello world"
        XCTAssertEqual(str.capitalized, "Hello World")
    }

    func testStringCapitalizeEach() {
        let str = "hello WORLD"
        XCTAssertEqual(str.capitalizingFirstLetterOfEachWord(), "Hello WORLD")
    }

    func testStringContains() {
        let str = "Hello World"
        XCTAssertTrue(str.contains("world"))
    }

    func testStringContainsIgnoreCase() {
        let str = "Hello World"
        XCTAssertTrue(str.containsIgnoreCase("WORLD"))
    }

    func testIntValueDefaultZero() {
        let str = "42"
        XCTAssertEqual(str.intValueDefaultZero, 42)
    }

    func testIntValueDefaultZeroEmpty() {
        let str = ""
        XCTAssertEqual(str.intValueDefaultZero, 0)
    }

    func testBoolValueDefaultFalse() {
        XCTAssertTrue("TRUE".boolValueDefaultFalse)
        XCTAssertFalse("FALSE".boolValueDefaultFalse)
        XCTAssertFalse("".boolValueDefaultFalse)
    }
}