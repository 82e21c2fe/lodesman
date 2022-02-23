//
//  PersistentStorageTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 30.01.2022.
//

import XCTest
import DomainPrimitives
@testable import lodesman

extension AttachmentStub
{
    static func fixture(link: URL? = URL(string: "https://example.home.arpa/bigfile.dat")!,
                        size: ContentSize = 12.5,
                        availability: Availability = 3) -> AttachmentStub
    {
        return AttachmentStub(link: link,
                              size: size,
                              availability: availability)
    }
}

extension TopicStub
{
    static func fixture(topicId: TopicId = 10,
                        status: TopicStatus = .approved,
                        title: TopicTitle = "test",
                        synopsis: String? = "synopsis",
                        attachment: AttachmentStub? = .fixture(),
                        lastUpdate: Date = Date(),
                        pinned: Bool = false) -> TopicStub
    {
        return TopicStub(topicId: topicId,
                         status: status,
                         title: title,
                         synopsis: synopsis,
                         attachment: attachment,
                         lastUpdate: lastUpdate,
                         pinned: pinned)
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
        let topic = TopicStub.fixture(topicId: 10)
        storage.insert(topics: [topic], toForum: 1)
        let result = try XCTUnwrap(storage.topic(withId:10))
        XCTAssertEqual(result.topicId, 10)
    }

    func testUpdateTopicWithSynopsisNotNil() throws {
        let persistent = Persistent(inMemory: true)
        let storage = persistent.topicStore
        let topic = TopicStub.fixture(topicId: 10, synopsis: "test")
        storage.insert(topics: [topic], toForum: 1)
        let result = try XCTUnwrap(storage.topic(withId:10))
        XCTAssertEqual(result.synopsis, "test")
        let secondTopic = TopicStub.fixture(topicId: 10, synopsis: "second")
        storage.insert(topics: [secondTopic], toForum: 1)
        let second = try XCTUnwrap(storage.topic(withId:10))
        XCTAssertEqual(second.synopsis, "second")
    }

    func testUpdateTopicWithSynopsisNil() throws {
        let persistent = Persistent(inMemory: true)
        let storage = persistent.topicStore
        let topic = TopicStub.fixture(topicId: 10, synopsis: "test")
        storage.insert(topics: [topic], toForum: 1)
        let result = try XCTUnwrap(storage.topic(withId:10))
        XCTAssertEqual(result.synopsis, "test")
        let secondTopic = TopicStub.fixture(topicId: 10, synopsis: nil)
        storage.insert(topics: [secondTopic], toForum: 1)
        let second = try XCTUnwrap(storage.topic(withId:10))
        XCTAssertEqual(second.synopsis, "test")
    }
}
