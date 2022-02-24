//
//  PersistentStorageTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 30.01.2022.
//

import XCTest
import DomainPrimitives
@testable import lodesman


struct TopicInfoStub: TopicInfo
{
    var topicId: TopicId
    var title: TopicTitle
    var status: TopicStatus
    var lastUpdate: Date
    var contentSize: ContentSize
    var availability: Availability
}

extension TopicInfoStub
{
    static func fixture(topicId: TopicId = 10,
                        title: TopicTitle = "test",
                        status: TopicStatus = .approved,
                        lastUpdate: Date = Date(),
                        contentSize: ContentSize = 12.5,
                        availability: Availability = 3) -> TopicInfoStub
    {
        return TopicInfoStub(topicId: topicId,
                             title: title,
                             status: status,
                             lastUpdate: lastUpdate,
                             contentSize: contentSize,
                             availability: availability)
    }
}

extension ForumInfo
{
    static func fixture(id: ForumId = 1,
                        title: ForumTitle = "Untitled",
                        section: ForumTitle = "Section") -> ForumInfo
    {
        return ForumInfo(id: id, title: title, section: section)
    }
}

class PersistentStorageTests: XCTestCase
{
    //MARK: - forum
    func testContainerWithoutForums() throws {
        let persistent = Persistent(inMemory: true)
        let storage = persistent.forumStore
        XCTAssertTrue(storage.forums.isEmpty)
    }

    func testInsertForumsInContainer() throws {
        let persistent = Persistent(inMemory: true)
        let storage = persistent.forumStore
        let forums: [ForumInfo] = [.fixture(id: 1, title: "beta"),
                                   .fixture(id: 2, title: "alpha")]
        storage.insert(forums: forums)
        XCTAssertEqual(storage.forums.count, 2)
        let first = try XCTUnwrap(storage.forums.first)
        XCTAssertEqual(first.id, 2)
        XCTAssertEqual(first.title, "alpha")
        XCTAssertEqual(first.numberOfTopics, 0)
        let last = try XCTUnwrap(storage.forums.last)
        XCTAssertEqual(last.id, 1)
        XCTAssertEqual(last.title, "beta")
        XCTAssertEqual(last.numberOfTopics, 0)
    }

    func testUpdateForumsInContainer() throws {
        let persistent = Persistent(inMemory: true)
        let storage = persistent.forumStore
        let forums: [ForumInfo] = [.fixture(id: 1, title: "beta"),
                                   .fixture(id: 2, title: "alpha")]
        storage.insert(forums: forums)
        XCTAssertEqual(storage.forums.count, 2)
        let newForums: [ForumInfo] = [.fixture(id: 2, title: "gamma"),
                                      .fixture(id: 3, title: "zeta")]
        storage.insert(forums: newForums)
        XCTAssertEqual(storage.forums.count, 3)
        let first = try XCTUnwrap(storage.forums.first)
        XCTAssertEqual(first.title, "beta")
        let second = try XCTUnwrap(storage.forums[1])
        XCTAssertEqual(second.id, 2)
        XCTAssertEqual(second.title, "gamma")
        let last = try XCTUnwrap(storage.forums.last)
        XCTAssertEqual(last.title, "zeta")
    }

    func testRemoveForumsFromEmptyContainer() throws {
        let persistent = Persistent(inMemory: true)
        let storage = persistent.forumStore
        XCTAssertTrue(storage.forums.isEmpty)
        storage.remove(forums: [5, 2])
        XCTAssertTrue(storage.forums.isEmpty)
    }

    func testRemoveForumsFromContainer() throws {
        let persistent = Persistent(inMemory: true)
        let storage = persistent.forumStore
        let forums: [ForumInfo] = [.fixture(id: 1, title: "beta"),
                                   .fixture(id: 2, title: "alpha"),
                                   .fixture(id: 5, title: "gamma"),
                                   .fixture(id: 12, title: "delta")]
        storage.insert(forums: forums)
        XCTAssertEqual(storage.forums.count, 4)
        storage.remove(forums: [5, 2])
        XCTAssertEqual(storage.forums.count, 2)
        let first = try XCTUnwrap(storage.forums.first)
        XCTAssertEqual(first.title, "beta")
        let last = try XCTUnwrap(storage.forums.last)
        XCTAssertEqual(last.title, "delta")
    }

    //MARK: - topic
    func testInsertTopicWithTopicId() throws {
        let persistent = Persistent(inMemory: true)
        let storage = persistent.topicStore
        let topic = TopicInfoStub.fixture(topicId: 10)
        storage.insert(topics: [topic], toForum: 1)
        let result = try XCTUnwrap(storage.topic(withId:10))
        XCTAssertEqual(result.id, 10)
    }
}
