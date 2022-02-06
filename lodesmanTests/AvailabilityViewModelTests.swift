//
//  AvailabilityViewModelTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 06.02.2022.
//

import XCTest
@testable import lodesman


class AvailabilityViewModelTests: XCTestCase
{
    func testZeroPoint() throws {
        let model = AvailabilityView.ViewModel(0)
        XCTAssertEqual(model.points, 0)
        XCTAssertEqual(model.text, "")
    }

    func testOnePoint() throws {
        let model = AvailabilityView.ViewModel(1)
        XCTAssertEqual(model.points, 1)
        XCTAssertEqual(model.text, "✦")
    }

    func testFivePoint() throws {
        let model = AvailabilityView.ViewModel(5)
        XCTAssertEqual(model.points, 5)
        XCTAssertEqual(model.text, "✦✦✦✦✦")
    }
}
