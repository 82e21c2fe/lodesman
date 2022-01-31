//
//  PersistentStorageTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 30.01.2022.
//

import XCTest
@testable import lodesman


class PersistentStorageTests: XCTestCase
{
    func testContainerWithoutForums() throws {
        let persistent = Persistent(inMemory: true)
        let storage = Storage(context: persistent.container.viewContext)
        XCTAssertTrue(storage.forums.isEmpty)
    }

    func testInsertForumsInContainer() throws {
        let persistent = Persistent(inMemory: true)
        let storage = Storage(context: persistent.container.viewContext)
        let forums = [(forumId: 1, title: "beta"),
                      (forumId: 2, title: "alpha")]
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
        let forums = [(forumId: 1, title: "beta"),
                      (forumId: 2, title: "alpha")]
        storage.insert(forums: forums)
        XCTAssertEqual(storage.forums.count, 2)
        let newForums = [(forumId: 2, title: "gamma"),
                         (forumId: 3, title: "zeta")]
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
        let forums = [(forumId: 1, title: "beta"),
                      (forumId: 2, title: "alpha"),
                      (forumId: 5, title: "gamma"),
                      (forumId: 12, title: "delta")]
        storage.insert(forums: forums)
        XCTAssertEqual(storage.forums.count, 4)
        storage.remove(forums: [5, 2])
        XCTAssertEqual(storage.forums.count, 2)
        let first = try XCTUnwrap(storage.forums.first)
        XCTAssertEqual(first.title, "beta")
        let last = try XCTUnwrap(storage.forums.last)
        XCTAssertEqual(last.title, "delta")
    }
}
