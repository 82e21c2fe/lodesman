//
//  PersistentStorageTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 30.01.2022.
//

import XCTest
@testable import lodesman


extension AttachmentStub
{
    static func fixture(link: URL? = URL(string: "https://example.home.arpa/bigfile.dat")!,
                        size: Float = 12.5,
                        availability: Int = 3) -> AttachmentStub
    {
        return AttachmentStub(link: link,
                              size: size,
                              availability: availability)
    }
}

extension TopicStub
{
    static func fixture(topicId: Int = 10,
                        status: TopicStatus = .approved,
                        title: String = "test",
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


class PersistentStorageTests: XCTestCase
{
    //MARK: - forum
    func testContainerWithoutForums() throws {
        let persistent = Persistent(inMemory: true)
        let storage = Storage(context: persistent.container.viewContext)
        XCTAssertTrue(storage.forums.isEmpty)
    }

    func testInsertForumsInContainer() throws {
        let persistent = Persistent(inMemory: true)
        let storage = Storage(context: persistent.container.viewContext)
        let forums = [(section: "main", forumId: 1, title: "beta"),
                      (section: "main", forumId: 2, title: "alpha")]
        storage.insert(forums: forums)
        XCTAssertEqual(storage.forums.count, 2)
        let first = try XCTUnwrap(storage.forums.first)
        XCTAssertEqual(first.forumId, 2)
        XCTAssertEqual(first.title, "alpha")
        XCTAssertEqual(first.numberOfTopics, 0)
        let last = try XCTUnwrap(storage.forums.last)
        XCTAssertEqual(last.forumId, 1)
        XCTAssertEqual(last.title, "beta")
        XCTAssertEqual(last.numberOfTopics, 0)
    }

    func testUpdateForumsInContainer() throws {
        let persistent = Persistent(inMemory: true)
        let storage = Storage(context: persistent.container.viewContext)
        let forums = [(section: "main", forumId: 1, title: "beta"),
                      (section: "main", forumId: 2, title: "alpha")]
        storage.insert(forums: forums)
        XCTAssertEqual(storage.forums.count, 2)
        let newForums = [(section: "main", forumId: 2, title: "gamma"),
                         (section: "main", forumId: 3, title: "zeta")]
        storage.insert(forums: newForums)
        XCTAssertEqual(storage.forums.count, 3)
        let first = try XCTUnwrap(storage.forums.first)
        XCTAssertEqual(first.title, "beta")
        let second = try XCTUnwrap(storage.forums[1])
        XCTAssertEqual(second.forumId, 2)
        XCTAssertEqual(second.title, "gamma")
        let last = try XCTUnwrap(storage.forums.last)
        XCTAssertEqual(last.title, "zeta")
    }

    func testRemoveForumsFromEmptyContainer() throws {
        let persistent = Persistent(inMemory: true)
        let storage = Storage(context: persistent.container.viewContext)
        XCTAssertTrue(storage.forums.isEmpty)
        storage.remove(forums: [5, 2])
        XCTAssertTrue(storage.forums.isEmpty)
    }

    func testRemoveForumsFromContainer() throws {
        let persistent = Persistent(inMemory: true)
        let storage = Storage(context: persistent.container.viewContext)
        let forums = [(section: "main", forumId: 1, title: "beta"),
                      (section: "main", forumId: 2, title: "alpha"),
                      (section: "main", forumId: 5, title: "gamma"),
                      (section: "main", forumId: 12, title: "delta")]
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
        let storage = Storage(context: persistent.container.viewContext)
        let topic = TopicStub.fixture(topicId: 10)
        storage.insert(topics: [topic], toForum: 1)
        let result = try XCTUnwrap(storage.topic(withId:10))
        XCTAssertEqual(result.topicId, 10)
    }

    func testUpdateTopicWithSynopsisNotNil() throws {
        let persistent = Persistent(inMemory: true)
        let storage = Storage(context: persistent.container.viewContext)
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
        let storage = Storage(context: persistent.container.viewContext)
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
