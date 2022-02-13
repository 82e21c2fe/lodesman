//
//  AvailabilityTests.swift
//  DomainPrimitivesTests
//
//  Created by Dmitri Shuvalov on 06.02.2022.
//

import XCTest
@testable import DomainPrimitives


class AvailabilityTests: XCTestCase
{
    func testLiteral() throws {
        let availability: Availability = 3
        XCTAssertEqual(availability.rawValue, 3)
    }

    func testNegativeRawValue() throws {
        XCTAssertNil(Availability(rawValue: -1))
    }

    func testTooBigRawValue() throws {
        XCTAssertNil(Availability(rawValue: 6))
    }

    func testNegativeSeeders() throws {
        XCTAssertNil(Availability(numberOfSeeders: -1))
    }

    func testZeroSeeders() throws {
        let availability = try XCTUnwrap(Availability(numberOfSeeders: 0))
        XCTAssertEqual(availability.rawValue, 0)
    }

    func testOneSeeder() throws {
        let availability = try XCTUnwrap(Availability(numberOfSeeders: 1))
        XCTAssertEqual(availability.rawValue, 1)
    }

    func testTwoSeeder() throws {
        let availability = try XCTUnwrap(Availability(numberOfSeeders: 2))
        XCTAssertEqual(availability.rawValue, 2)
    }


    func testTenSeeders() throws {
        let availability = try XCTUnwrap(Availability(numberOfSeeders: 10))
        XCTAssertEqual(availability.rawValue, 3)
    }

    func testThousandSeeders() throws {
        let availability = try XCTUnwrap(Availability(numberOfSeeders: 1_000))
        XCTAssertEqual(availability.rawValue, 5)
    }

    func testComparsion() throws {
        let lhs = try XCTUnwrap(Availability(rawValue: 2))
        let rhs = try XCTUnwrap(Availability(rawValue: 4))
        XCTAssertTrue(lhs < rhs)
        XCTAssertFalse(rhs < lhs)
        XCTAssertFalse(lhs == rhs)
    }
}
