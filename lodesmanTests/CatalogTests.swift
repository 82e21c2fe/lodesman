//
//  CatalogTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 24.01.2022.
//

import XCTest
@testable import lodesman


fileprivate struct ItemStub: CatalogItem
{
    var id: Int = 0
    var kind: CatalogItemKind = .section
    var title: ForumTitle = "Untitled"
    var children: [CatalogItem]?
}

fileprivate struct CatalogStub: Catalog
{
    var root: [CatalogItem] = []
}


class CatalogTests: XCTestCase
{
    func testForEachWithEmptyCatalog() throws {
        var called = false
        let catalog = CatalogStub()
        catalog.forEach { _ in
            called = true
        }
        XCTAssertFalse(called)
    }

    func testForEachWithOneEmptySection() throws {
        var called = false
        var result = [CatalogItem]()
        let catalog = CatalogStub(root: [ItemStub(id: -1, kind: .section, title: "test")])
        catalog.forEach { item in
            called = true
            result.append(item)
        }
        XCTAssertTrue(called)
        XCTAssertEqual(result.count, 1)
        let item = try XCTUnwrap(result.first)
        XCTAssertEqual(item.id, -1)
        XCTAssertEqual(item.kind, .section)
        XCTAssertEqual(item.title, "test")
        XCTAssertNil(item.children)
    }

    func testForEachWithTwoEmptySection() throws {
        var called = false
        let inputItems = [ItemStub(id: -1),
                          ItemStub(id: -2)]
        var result = [CatalogItem]()
        let catalog = CatalogStub(root: inputItems)
        catalog.forEach { item in
            called = true
            result.append(item)
        }
        XCTAssertTrue(called)
        XCTAssertEqual(result.count, 2)
        let firstItem = try XCTUnwrap(result.first)
        XCTAssertEqual(firstItem.id, -1)
        let lastItem = try XCTUnwrap(result.last)
        XCTAssertEqual(lastItem.id, -2)
    }

    func testForEachWithOneSectionAndTwoNestingLevels() throws {
        var called = false
        let inputItems = [ItemStub(id: -1, children: [ItemStub(id: 1, children: [ItemStub(id: 2)])])]
        var result = [CatalogItem]()
        let catalog = CatalogStub(root: inputItems)
        catalog.forEach { item in
            called = true
            result.append(item)
        }
        XCTAssertTrue(called)
        XCTAssertEqual(result.count, 3)
        let first = try XCTUnwrap(result[0])
        XCTAssertEqual(first.id, -1)
        let second = try XCTUnwrap(result[1])
        XCTAssertEqual(second.id, 1)
        let third = try XCTUnwrap(result[2])
        XCTAssertEqual(third.id, 2)
    }
}
