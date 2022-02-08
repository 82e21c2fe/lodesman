//
//  TopicListViewModelTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 25.01.2022.
//

import XCTest
@testable import lodesman


extension TopicStub
{
    fileprivate static func fixture(topicId: TopicId = 0,
                                    pinned: Bool = false,
                                    title: TopicTitle = "untitled",
                                    lastUpdate: Date = Date()) -> TopicStub
    {
        return TopicStub(topicId: topicId, title: title, lastUpdate: lastUpdate, pinned: pinned)
    }
}


class TopicListViewModelTests: XCTestCase
{
    //MARK: - by day
    func testGroupByDayWithEmptyList() throws {
        let topics: [Topic] = []
        let model = TopicListView.ViewModel(topics, groupRule: .byDay)
        XCTAssertTrue(model.section.isEmpty)
    }

    func testGroupByDayWithOneSection() throws {
        let today = Calendar.current.startOfDay(for: Date())
        let topics: [TopicStub] = [.fixture(topicId: 1, lastUpdate: today.advanced(by: 4000)),
                                   .fixture(topicId: 2, lastUpdate: today.advanced(by: 1000))]
        let model = TopicListView.ViewModel(topics, groupRule: .byDay)
        XCTAssertEqual(model.section.count, 1)
        let section = try XCTUnwrap(model.section.first)
        XCTAssertEqual(section.caption, "Today")
        XCTAssertEqual(section.topics.count, 2)
        XCTAssertEqual(section.topics.first?.topicId, 1)
        XCTAssertEqual(section.topics.last?.topicId, 2)
    }

    func testGroupByDayWithTwoSections() throws {
        let today = Calendar.current.startOfDay(for: Date())
        let topics: [TopicStub] = [.fixture(topicId: 1, lastUpdate: today.advanced(by: 8000)),
                                   .fixture(topicId: 2, lastUpdate: today.advanced(by: -8000))]
        let model = TopicListView.ViewModel(topics, groupRule: .byDay)
        XCTAssertEqual(model.section.count, 2)
        let firstSection = try XCTUnwrap(model.section.first)
        XCTAssertEqual(firstSection.caption, "Today")
        XCTAssertEqual(firstSection.topics.count, 1)
        XCTAssertEqual(firstSection.topics.first?.topicId, 1)
        let lastSection = try XCTUnwrap(model.section.last)
        XCTAssertEqual(lastSection.caption, "Yesterday")
        XCTAssertEqual(lastSection.topics.count, 1)
        XCTAssertEqual(lastSection.topics.first?.topicId, 2)
    }

    func testGroupByDayWithPinnedSection() throws {
        let today = Calendar.current.startOfDay(for: Date())
        let topics: [TopicStub] = [.fixture(topicId: 1, pinned: false, lastUpdate: today.advanced(by: 8000)),
                                   .fixture(topicId: 2, pinned: true, lastUpdate: today.advanced(by: -8000))]
        let model = TopicListView.ViewModel(topics, groupRule: .byDay)
        XCTAssertEqual(model.section.count, 2)
        let firstSection = try XCTUnwrap(model.section.first)
        XCTAssertEqual(firstSection.caption, "Pinned")
        XCTAssertEqual(firstSection.topics.count, 1)
        XCTAssertEqual(firstSection.topics.first?.topicId, 2)
        let lastSection = try XCTUnwrap(model.section.last)
        XCTAssertEqual(lastSection.caption, "Today")
        XCTAssertEqual(lastSection.topics.count, 1)
        XCTAssertEqual(lastSection.topics.first?.topicId, 1)
    }


    //MARK: - by alphabet
    func testGroupByAlphabetWithEmptyList() throws {
        let topics = [TopicStub]()
        let model = TopicListView.ViewModel(topics, groupRule: .byAlphabet)
        XCTAssertTrue(model.section.isEmpty)
    }

    func testGroupByAlphabetWithOneSection() throws {
        let topics: [TopicStub] = [.fixture(topicId: 1, title: "Bar"),
                                   .fixture(topicId: 2, title: "baz")]
        let model = TopicListView.ViewModel(topics, groupRule: .byAlphabet)
        XCTAssertEqual(model.section.count, 1)
        let section = try XCTUnwrap(model.section.first)
        XCTAssertEqual(section.caption, "B")
        XCTAssertEqual(section.topics.count, 2)
        XCTAssertEqual(section.topics.first?.topicId, 1)
        XCTAssertEqual(section.topics.last?.topicId, 2)

    }

    func testGroupByAlphabetWithTwoSections() throws {
        let topics: [TopicStub] = [.fixture(topicId: 1, title: "Beta"),
                                   .fixture(topicId: 2, title: "alpha")]
        let model = TopicListView.ViewModel(topics, groupRule: .byAlphabet)
        XCTAssertEqual(model.section.count, 2)
        let firstSection = try XCTUnwrap(model.section.first)
        XCTAssertEqual(firstSection.caption, "A")
        XCTAssertEqual(firstSection.topics.count, 1)
        XCTAssertEqual(firstSection.topics.first?.topicId, 2)
        let lastSection = try XCTUnwrap(model.section.last)
        XCTAssertEqual(lastSection.caption, "B")
        XCTAssertEqual(lastSection.topics.count, 1)
        XCTAssertEqual(lastSection.topics.first?.topicId, 1)
    }

    func testGroupByAlphabetWithPinnedSection() throws {
        let topics: [TopicStub] = [.fixture(topicId: 1, pinned: false, title: "gamma"),
                                   .fixture(topicId: 2, pinned: true, title: "zeta")]
        let model = TopicListView.ViewModel(topics, groupRule: .byAlphabet)
        XCTAssertEqual(model.section.count, 2)
        let firstSection = try XCTUnwrap(model.section.first)
        XCTAssertEqual(firstSection.caption, "Pinned")
        XCTAssertEqual(firstSection.topics.count, 1)
        XCTAssertEqual(firstSection.topics.first?.topicId, 2)
        let lastSection = try XCTUnwrap(model.section.last)
        XCTAssertEqual(lastSection.caption, "G")
        XCTAssertEqual(lastSection.topics.count, 1)
        XCTAssertEqual(lastSection.topics.first?.topicId, 1)
    }
}
