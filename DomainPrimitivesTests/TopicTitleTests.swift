//
//  TopicTitleTests.swift
//  DomainPrimitivesTests
//
//  Created by Dmitri Shuvalov on 08.02.2022.
//

import XCTest
@testable import DomainPrimitives


class TopicTitleTests: XCTestCase
{
    func testLiteral() throws {
        let title: TopicTitle = "test"
        XCTAssertEqual(title.rawValue, "test")
    }

    func testTooShortRawValue() throws {
        XCTAssertNil(TopicTitle(rawValue: "x"))
    }

    func testTooLongRawValue() throws {
        let longtitle = String(repeating: "a", count: 257)
        XCTAssertNil(TopicTitle(rawValue: longtitle))
    }

    func testRawValueWithSpace() throws {
        let title = try XCTUnwrap(TopicTitle(rawValue: " \t gamma 1\n"))
        XCTAssertEqual(title.rawValue, "gamma 1")
    }

    func testFirstLetterStartsWithLetter() throws {
        let title = try XCTUnwrap(TopicTitle(rawValue: "beta"))
        XCTAssertEqual(title.firstLetter, "B")
    }

    func testFirstLetterStartsWithNumber() throws {
        let title = try XCTUnwrap(TopicTitle(rawValue: "1984"))
        XCTAssertEqual(title.firstLetter, "1")
    }

    func testFirstLetterStartsWithBrackets() throws {
        let title = try XCTUnwrap(TopicTitle(rawValue: "{[collection] (lossless) master} guitar"))
        XCTAssertEqual(title.firstLetter, "G")
    }

    func testComparsion() throws {
        let lhs = try XCTUnwrap(TopicTitle(rawValue: "Alpha"))
        let rhs = try XCTUnwrap(TopicTitle(rawValue: "zeta"))
        XCTAssertTrue(lhs < rhs)
        XCTAssertFalse(rhs < lhs)
        XCTAssertFalse(lhs == rhs)
    }
}
