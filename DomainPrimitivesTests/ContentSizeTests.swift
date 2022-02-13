//
//  ContentSizeTests.swift
//  DomainPrimitivesTests
//
//  Created by Dmitri Shuvalov on 06.02.2022.
//

import XCTest
@testable import DomainPrimitives


class ContentSizeTests: XCTestCase
{
    func testIntegerLiteral() throws {
        let size: ContentSize = 5
        XCTAssertEqual(size.rawValue, 5)
    }

    func testFloatLiteral() throws {
        let size: ContentSize = 12.3
        XCTAssertEqual(size.rawValue, 12.3)
    }

    func testNegativeRawValue() throws {
        XCTAssertNil(ContentSize(rawValue: -1))
    }

    func testNanRawValue() throws {
        XCTAssertNil(ContentSize(rawValue: .nan))
    }

    func testInfinityRawValue() throws {
        XCTAssertNil(ContentSize(rawValue: .infinity))
    }

    func testTooBigRawValue() throws {
        XCTAssertNil(ContentSize(rawValue: 1_025))
    }

    func testMeasurmentKB() throws {
        let size = try XCTUnwrap(ContentSize(rawValue: 0.00045))
        XCTAssertEqual(size.measurement.converted(to: .kilobytes).value.rounded(), 450)
    }

    func testMeasurmentMB() throws {
        let size = try XCTUnwrap(ContentSize(rawValue: 0.032))
        XCTAssertEqual(size.measurement.converted(to: .megabytes).value.rounded(), 32)
    }

    func testInitWithEmptyString() throws {
        XCTAssertNil(ContentSize(""))
    }

    func testInitWithLongString() throws {
        XCTAssertNil(ContentSize("1234567890123456789 GB"))
    }

    func testInitWithNegativeString() throws {
        XCTAssertNil(ContentSize("-25 GB"))
    }

    func testInitWithKBString() throws {
        let size = try XCTUnwrap(ContentSize("987.65 KB"))
        XCTAssertEqual(size.measurement.converted(to: .bytes).value.rounded(), 987650)
    }

    func testInitWithMBString() throws {
        let size = try XCTUnwrap(ContentSize("12.3 MB"))
        XCTAssertEqual(size.measurement.converted(to: .kilobytes).value.rounded(), 12300)
    }

    func testInitWithGBString() throws {
        let size = try XCTUnwrap(ContentSize("5 GB"))
        XCTAssertEqual(size.measurement.value, 5)
    }

    func testComparsion() throws {
        let lhs = try XCTUnwrap(ContentSize(rawValue: 2))
        let rhs = try XCTUnwrap(ContentSize(rawValue: 5))
        XCTAssertTrue(lhs < rhs)
        XCTAssertFalse(rhs < lhs)
        XCTAssertFalse(lhs == rhs)
    }
}
