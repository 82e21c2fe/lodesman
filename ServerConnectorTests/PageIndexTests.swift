//
//  PageIndexTests.swift
//  ServerConnectorTests
//
//  Created by Dmitri Shuvalov on 14.02.2022.
//

import XCTest
@testable import ServerConnector


class PageIndexTests: XCTestCase
{
    func testIntegerLiteral() throws {
        let idx: PageIndex = 312
        XCTAssertEqual(idx.rawValue, 312)
    }

    func testNegativeRawValue() throws {
        XCTAssertNil(PageIndex(rawValue: -1))
    }

    func testZeroRawValue() throws {
        XCTAssertNil(PageIndex(rawValue: 0))
    }

    func testPositiveRawValue() throws {
        let idx = try XCTUnwrap(PageIndex(rawValue: 1))
        XCTAssertEqual(idx.rawValue, 1)
    }

    func testMaxPositiveRawValue() throws {
        let idx = try XCTUnwrap(PageIndex(rawValue: 600))
        XCTAssertEqual(idx.rawValue, 600)
    }

    func testTooBigPositiveRawValue() throws {
        XCTAssertNil(PageIndex(rawValue: 601))
    }

    func testInitWithEmptyString() throws {
        XCTAssertNil(PageIndex(""))
    }

    func testInitWithTooLongString() throws {
        XCTAssertNil(PageIndex("1234"))
    }

    func testInitWithNegativeString() throws {
        XCTAssertNil(PageIndex("-54"))
    }

    func testInitWithZeroString() throws {
        XCTAssertNil(PageIndex("0"))
    }

    func testInitWithZeroLeadingString() throws {
        let idx = try XCTUnwrap(PageIndex("010"))
        XCTAssertEqual(idx.rawValue, 10)
    }

    func testDescriptionString() throws {
        let idx = try XCTUnwrap(PageIndex(rawValue: 65))
        XCTAssertEqual(idx.description, "65")
    }

    func testComparsion() throws {
        let lhs = try XCTUnwrap(PageIndex(rawValue: 2))
        let rhs = try XCTUnwrap(PageIndex(rawValue: 3))
        XCTAssertTrue(lhs < rhs)
        XCTAssertFalse(rhs < lhs)
        XCTAssertFalse(lhs == rhs)
    }

    func testTopicOffsetAtFirstPage() throws {
        let idx = PageIndex.first
        XCTAssertEqual(idx.topicOffset, 0)
    }

    func testTopicOffsetAtSecondPage() throws {
        let idx: PageIndex = 2
        XCTAssertEqual(idx.topicOffset, 50)
    }
}
