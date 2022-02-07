//
//  TopicIdTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 07.02.2022.
//

import XCTest
@testable import lodesman


class TopicIdTests: XCTestCase
{
    func testIntegerLiteral() throws {
        let id: TopicId = 12
        XCTAssertEqual(id.rawValue, 12)
    }

    func testNegativeRawValue() throws {
        XCTAssertNil(TopicId(rawValue: -1))
    }

    func testZeroRawValue() throws {
        XCTAssertNil(TopicId(rawValue: 0))
    }

    func testPositiveRawValue() throws {
        let id = try XCTUnwrap(TopicId(rawValue: 3))
        XCTAssertEqual(id.rawValue, 3)
    }

    func testInitWithEmptyString() throws {
        XCTAssertNil(TopicId(""))
    }

    func testInitWithTooLongString() throws {
        XCTAssertNil(TopicId("123456789012345678901"))
    }

    func testInitWithNegativeString() throws {
        XCTAssertNil(TopicId("-5"))
    }

    func testInitWithZeroString() throws {
        XCTAssertNil(TopicId("0"))
    }

    func testInitWithZeroLeadingString() throws {
        let id = try XCTUnwrap(TopicId("0000010"))
        XCTAssertEqual(id.rawValue, 10)
    }

    func testDescriptionString() throws {
        let id = try XCTUnwrap(TopicId(rawValue: 98765))
        XCTAssertEqual(id.description, "98765")
    }
}
