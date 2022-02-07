//
//  ForumIdTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 07.02.2022.
//

import XCTest
@testable import lodesman


class ForumIdTests: XCTestCase
{
    func testIntegerLiteral() throws {
        let id: ForumId = 312
        XCTAssertEqual(id.rawValue, 312)
    }

    func testNegativeRawValue() throws {
        XCTAssertNil(ForumId(rawValue: -1))
    }

    func testZeroRawValue() throws {
        XCTAssertNil(ForumId(rawValue: 0))
    }

    func testPositiveRawValue() throws {
        let id = try XCTUnwrap(ForumId(rawValue: 33))
        XCTAssertEqual(id.rawValue, 33)
    }

    func testInitWithEmptyString() throws {
        XCTAssertNil(ForumId(""))
    }

    func testInitWithTooLongString() throws {
        XCTAssertNil(ForumId("123456789012345678901"))
    }

    func testInitWithNegativeString() throws {
        XCTAssertNil(ForumId("-54"))
    }

    func testInitWithZeroString() throws {
        XCTAssertNil(ForumId("0"))
    }

    func testInitWithZeroLeadingString() throws {
        let id = try XCTUnwrap(ForumId("0000010"))
        XCTAssertEqual(id.rawValue, 10)
    }

    func testDescriptionString() throws {
        let id = try XCTUnwrap(ForumId(rawValue: 498765))
        XCTAssertEqual(id.description, "498765")
    }
}
