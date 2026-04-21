//
//  ExtensionTests.swift
//  Still Alive LarpTests
//
//  Tests for String, Int, Date extensions
//

import XCTest
@testable import StillAliveLarp

class ExtensionTests: BaseTestClass {

    // MARK: - String Extensions

    func testStringCapitalize() {
        let str = "hello world"
        XCTAssertEqual(str.capitalized, "Hello World")
    }

    func testStringCapitalizeFirstLetterOfEachWord() {
        let str = "hello WORLD"
        XCTAssertEqual(str.capitalizingFirstLetterOfEachWord(), "Hello World")
        
        let title = "this is a title or a name"
        XCTAssertEqual(title.capitalizingFirstLetterOfEachWord(), "This Is A Title Or A Name")
    }

    func testStringContains() {
        let str = "Hello World"
        XCTAssertFalse(str.contains("world"))
        XCTAssertTrue(str.contains("World"))
        XCTAssertFalse(str.contains("universe"))
    }

    func testStringContainsIgnoreCase() {
        let str = "Hello my name is Rydge"
        XCTAssertFalse(str.contains("hello my"))
        XCTAssertTrue(str.containsIgnoreCase("hello my"))
    }

    func testEqualsIgnoreCase() {
        let casedString = "ThIs Is A StRiNg"
        let lowercasedString = "this is a string"
        XCTAssertFalse(casedString == lowercasedString)
        XCTAssertTrue(casedString.equalsIgnoreCase(lowercasedString))
    }

func testEqualsAnyOf() {
        let value = 10
        XCTAssertTrue(value.equalsAnyOf([5, 15, 10, 12]))
        XCTAssertFalse(value.equalsAnyOf([5, 15, 1, 12]))
    }

    // MARK: - Int Extensions

    func testIntValueDefaultZero() {
        let str = "42"
        XCTAssertEqual(str.intValueDefaultZero, 42)
    }

    func testIntValueDefaultZeroEmpty() {
        let str = ""
        XCTAssertEqual(str.intValueDefaultZero, 0)
    }

    func testStringValue() {
        let num = 42
        let str = num.stringValue
        XCTAssertEqual(str, "42")
    }

    // MARK: - Bool Extensions

    func testBoolValueDefaultFalse() {
        XCTAssertTrue("TRUE".boolValueDefaultFalse)
        XCTAssertFalse("FALSE".boolValueDefaultFalse)
        XCTAssertFalse("".boolValueDefaultFalse)
    }

    // MARK: - Date Extensions

    func testYyyyMMddFormatted() {
        let date = Date()
        let formatted = date.yyyyMMddFormatted
        XCTAssertFalse(formatted.isEmpty)
        XCTAssertTrue(formatted.contains("/"))
    }

    func testYyyyMMddToMonthDayYear() {
        let dateStr = "2023/06/15"
        let converted = dateStr.yyyyMMddToMonthDayYear()
        XCTAssertEqual(converted, "June 15th, 2023")
    }

    func testYyyyMMddToDate() {
        let dateStr = "2023/06/15"
        let date = dateStr.yyyyMMddtoDate()
        XCTAssertNotNil(date)
    }

    // MARK: - Array Extensions

    func testArrayContainsWhere() {
        let arr = [1, 2, 3, 4, 5]
        XCTAssertTrue(arr.contains(where: { $0 > 3 }))
        XCTAssertFalse(arr.contains(where: { $0 > 10 }))
    }

    func testArrayFilterWhere() {
        let arr = [1, 2, 3, 4, 5]
        let filtered = arr.filter({ $0 > 2 })
        XCTAssertEqual(filtered.count, 3)
    }

    func testArrayFirstWhere() {
        let arr = [1, 2, 3, 4, 5]
        let found = arr.first(where: { $0 > 2 })
        XCTAssertEqual(found, 3)
    }
}
