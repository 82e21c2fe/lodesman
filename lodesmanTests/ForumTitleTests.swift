//
//  ForumTitleTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 08.02.2022.
//

import XCTest
@testable import lodesman


class ForumTitleTests: XCTestCase
{
    func testLiteral() throws {
        let title: ForumTitle = "test"
        XCTAssertEqual(title.rawValue, "test")
    }

    func testTooShortRawValue() throws {
        XCTAssertNil(ForumTitle(rawValue: "x"))
    }

    func testTooLongRawValue() throws {
        let longtitle = String(repeating: "a", count: 129)
        XCTAssertNil(ForumTitle(rawValue: longtitle))
    }

    func testRawValueWithSpace() throws {
        let title = try XCTUnwrap(ForumTitle(rawValue: " \t beta 12\n"))
        XCTAssertEqual(title.rawValue, "beta 12")
    }

    func testComparsion() throws {
        let lhs = try XCTUnwrap(ForumTitle(rawValue: "Alpha"))
        let rhs = try XCTUnwrap(ForumTitle(rawValue: "zeta"))
        XCTAssertTrue(lhs < rhs)
        XCTAssertFalse(rhs < lhs)
        XCTAssertFalse(lhs == rhs)
    }
}
