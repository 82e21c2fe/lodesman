//
//  CatalogPageTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 29.01.2022.
//

import XCTest
@testable import lodesman


extension CatalogPage.Forum
{
    static func xmlFixture(href: String = "22",
                           title: String = "title",
                           subforums: [XMLElement] = []) -> XMLElement
    {
        let nodes = subforums.map(\.xmlString).joined(separator: "\n")
        let forums = subforums.isEmpty ? "" : "<ul>\(nodes)</ul>"
        let text = "<li><span><a href='\(href)'>\(title)</a></span>\(forums)</li>"
        return try! XMLElement(xmlString: text)
    }
}

extension CatalogPage.Section
{
    static func xmlFixture(title: String = "title",
                           forums: [XMLElement] = [CatalogPage.Forum.xmlFixture()]) -> XMLElement
    {
        let nodes = forums.map(\.xmlString).joined(separator: "\n")
        let subforums = forums.isEmpty ? "" : "<ul>\(nodes)</ul>"
        let text = "<li><span class='b'><span class='c-title' title='\(title)'></span></span>\(subforums)</li>"
        return try! XMLElement(xmlString: text)
    }
}


class CatalogPageTests: XCTestCase
{
    //MARK: - Forum item
    func testForumInitFromXMLNodeWithNonIntegerHREF() throws {
        let node = CatalogPage.Forum.xmlFixture(href: "/subforum.php")
        XCTAssertNil(CatalogPage.Forum(node))
    }

    func testForumInitFromXMLNodeWithZeroHREF() throws {
        let node = CatalogPage.Forum.xmlFixture(href: "0")
        XCTAssertNil(CatalogPage.Forum(node))
    }

    func testForumInitFromXMLNodeWithNegativeHREF() throws {
        let node = CatalogPage.Forum.xmlFixture(href: "-1")
        XCTAssertNil(CatalogPage.Forum(node))
    }

    func testForumInitFromXMLNodeWithEmptyAnchorText() throws {
        let node = CatalogPage.Forum.xmlFixture(href: " ")
        XCTAssertNil(CatalogPage.Forum(node))
    }

    func testForumInitFromXMLNodeWithTooLongAnchorText() throws {
        let longname = String(repeating: "a", count: 129)
        let node = CatalogPage.Forum.xmlFixture(title: longname)
        XCTAssertNil(CatalogPage.Forum(node))
    }

    func testForumInitFromXMLNodeWithMaximumLengthAnchorText() throws {
        let longname = String(repeating: "a", count: 128)
        let node = CatalogPage.Forum.xmlFixture(title: longname)
        let forum = try XCTUnwrap(CatalogPage.Forum(node))
        XCTAssertEqual(forum.title.rawValue, longname)
    }

    func testForumInitFromXMLNodeWithoutSubforums() throws {
        let node = CatalogPage.Forum.xmlFixture(href: "10", title: "forum name")
        let forum = try XCTUnwrap(CatalogPage.Forum(node))
        XCTAssertEqual(forum.forumId, 10)
        XCTAssertEqual(forum.title, "forum name")
        XCTAssertTrue(forum.subforums.isEmpty)
    }

    func testForumInitFromXMLNodeWithOneSubforum() throws {
        let node = CatalogPage.Forum.xmlFixture(href: "10", title: "forum 10", subforums: [
            CatalogPage.Forum.xmlFixture(href: "11", title: "forum 11")
        ])
        let forum = try XCTUnwrap(CatalogPage.Forum(node))
        XCTAssertEqual(forum.forumId, 10)
        XCTAssertEqual(forum.title, "forum 10")
        XCTAssertEqual(forum.subforums.count, 1)
        let subforum = try XCTUnwrap(forum.subforums.first)
        XCTAssertEqual(subforum.forumId, 11)
        XCTAssertEqual(subforum.title, "forum 11")
        XCTAssertTrue(subforum.subforums.isEmpty)
    }

    //MARK: - Section item
    func testSectionInitFromXMLNodeWithoutCTitle() throws {
        let text = """
            <li><span class='b'></span>
                <ul><li><span class='b'><a href="638">title of forum 638</a></span></li></ul>
            </li>
            """
        let node = try XMLElement(xmlString: text)
        XCTAssertNil(CatalogPage.Section(node))
    }

    func testSectionInitFromXMLNodeWithEmptyCTitle() throws {
        let node = CatalogPage.Section.xmlFixture(title: "")
        XCTAssertNil(CatalogPage.Section(node))
    }

    func testSectionInitFromXMLNodeWithoutForums() throws {
        let node = CatalogPage.Section.xmlFixture(forums: [])
        XCTAssertNil(CatalogPage.Section(node))
    }

    func testSectionInitFromXMLNodeWithOneForum() throws {
        let node = CatalogPage.Section.xmlFixture(title: "section title", forums: [
            CatalogPage.Forum.xmlFixture(href: "638", title: "title of forum 638")
        ])
        let section = try XCTUnwrap(CatalogPage.Section(node))
        XCTAssertEqual(section.title, "section title")
        XCTAssertFalse(section.forums.isEmpty)
        let forum = try XCTUnwrap(section.forums.first)
        XCTAssertEqual(forum.forumId, 638)
        XCTAssertEqual(forum.title, "title of forum 638")
        XCTAssertTrue(forum.subforums.isEmpty)
    }

    //MARK: - Catalog page

    func testCatalogPageInitFromEmptyData() throws {
        XCTAssertThrowsError(try CatalogPage(data: Data()))
    }

    func testCatalogPageInitFromDataWithoutSection() throws {
        let testData = """
        <!DOCTYPE html>
        <body><div id="f-map">
        <ul class='tree-root'>
        </ul>
        </div></body>
        """.data(using: .windowsCP1251)!

        XCTAssertNoThrow(try CatalogPage(data: testData))
        let page = try CatalogPage(data: testData)
        XCTAssert(page.sections.isEmpty)
    }

    func testCatalogPageInitFromDataWithOneSection() throws {
        let testData = """
        <!DOCTYPE html>
        <body><div id="f-map">
        <ul class='tree-root'>
            <li><span class='b'><span class="c-title" title="section title"></span></span>
                <ul><li><span class='b'><a href="638">title of forum 638</a></span></li>
                    <li><span class='b'><a href="2346">title of forum 2346</a></span>
                        <ul><li><span><a href="928">title of forum 928</a></span></li>
                            <li><span><a href="925">title of forum 925</a></span></li>
                        </ul>
                    </li>
                </ul>
            </li>
        </ul>
        </div></body>
        """.data(using: .windowsCP1251)!

        XCTAssertNoThrow(try CatalogPage(data: testData))
        let page = try CatalogPage(data: testData)
        XCTAssertEqual(page.sections.count, 1)
        let section = try XCTUnwrap(page.sections.first)
        XCTAssertEqual(section.title, "section title")
        XCTAssertEqual(section.forums.count, 2)
    }
}
