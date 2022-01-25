//
//  TopicRowViewModelTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 25.01.2022.
//

import XCTest
@testable import lodesman



class TopicRowViewModelTests: XCTestCase
{
    //MARK: - Availability
    func testTopicWithAvailabilityZeroPoint() throws {
        let topic = TopicStub(availability: 0)
        let model = TopicRow.ViewModel(topic)
        XCTAssertEqual(model.availability, "")
    }

    func testTopicWithAvailabilityOnePoint() throws {
        let topic = TopicStub(availability: 1)
        let model = TopicRow.ViewModel(topic)
        XCTAssertEqual(model.availability, "✦")
    }

    func testTopicWithAvailabilityFivePoint() throws {
        let topic = TopicStub(availability: 5)
        let model = TopicRow.ViewModel(topic)
        XCTAssertEqual(model.availability, "✦✦✦✦✦")
    }

    //MARK: - ContentSize
    func testTopicWithContentSizeInGB() throws {
        let topic = TopicStub(contentSize: 15.2)
        let model = TopicRow.ViewModel(topic)
        XCTAssertEqual(model.contentSize, "15.2 GB")
    }

    func testTopicWithContentSizeInMB() throws {
        let topic = TopicStub(contentSize: 0.3)
        let model = TopicRow.ViewModel(topic)
        XCTAssertEqual(model.contentSize, "300 MB")
    }
}
