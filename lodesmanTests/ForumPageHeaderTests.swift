//
//  ForumPageHeaderTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 01.02.2022.
//

import XCTest
@testable import lodesman


extension ForumPage.Header
{
    static func xmlFixture(href: String = "viewforum.php?f=1600",
                           title: String = "forum title",
                           description: String? = nil,
                           pageIndices: String = "Страница: 1") -> XMLElement
    {
        let descriptionNode = description != nil ? "<div class='forum-desc-in-title'>\(description!)</div>" : ""
        let test = """
            <td>
                <h1 class="maintitle"><a href="\(href)">\(title)</a></h1>
                \(descriptionNode)
                <div class="small">
                    <b>\(pageIndices)</b>
                </div>
            </td>
            """
        return try! XMLElement(xmlString: test)
    }
}


class ForumPageHeaderTests: XCTestCase
{
    //MARK: - forumId
    func testHeaderWithHREF() throws {
        let node = ForumPage.Header.xmlFixture(href: "text")
        let header = try XCTUnwrap(ForumPage.Header(node))
        XCTAssertEqual(header.href, "text")
    }
    
    //MARK: - title
    func testHeaderWithEmptyTitle() throws {
        let node = ForumPage.Header.xmlFixture(title: " ")
        XCTAssertNil(ForumPage.Header(node))
    }

    func testHeaderWithVeryLongTitle() throws {
        let title = String(repeating: "a", count: 257)
        let node = ForumPage.Header.xmlFixture(title: title)
        XCTAssertNil(ForumPage.Header(node))
    }

    func testHeaderWithMaximumLengthTitle() throws {
        let title = String(repeating: "a", count: 256)
        let node = ForumPage.Header.xmlFixture(title: title)
        let header = try XCTUnwrap(ForumPage.Header(node))
        XCTAssertEqual(header.title, title)
    }

    func testHeaderWithTitle() throws {
        let node = ForumPage.Header.xmlFixture(title: "title")
        let header = try XCTUnwrap(ForumPage.Header(node))
        XCTAssertEqual(header.title, "title")
    }

    //MARK: - description
    func testHeaderWithoutDescription() throws {
        let node = ForumPage.Header.xmlFixture(description: nil)
        let header = try XCTUnwrap(ForumPage.Header(node))
        XCTAssertEqual(header.description, nil)
    }

    func testHeaderWithEmptyDescription() throws {
        let node = ForumPage.Header.xmlFixture(description: " ")
        let header = try XCTUnwrap(ForumPage.Header(node))
        XCTAssertEqual(header.description, nil)
    }

    func testHeaderWithDescription() throws {
        let node = ForumPage.Header.xmlFixture(description: "description")
        let header = try XCTUnwrap(ForumPage.Header(node))
        XCTAssertEqual(header.description, "description")
    }

    //MARK: - indices
    func testHeaderWithSinglePageIndex() throws {
        let node = ForumPage.Header.xmlFixture(pageIndices: "Страница: 1")
        let header = try XCTUnwrap(ForumPage.Header(node))
        XCTAssertEqual(header.currentPageIndex, 1)
        XCTAssertEqual(header.lastPageIndex, 1)
    }

    func testHeaderWithFirstPageIndex() throws {
        let testPaginator = """
            <span class="pg-jump-menu"><a class="menu-root" href="#pg-jump">Страница</a> :  </span>
            <b>1</b>,
            <a class="pg" href="">2</a>,
            <a class="pg" href="">3</a> ...
            <a class="pg" href="">496</a>,
            <a class="pg" href="">497</a>,
            <a class="pg" href="">498</a>
            <a class="pg" href="">След.</a>
            """
        let node = ForumPage.Header.xmlFixture(pageIndices: testPaginator)
        let header = try XCTUnwrap(ForumPage.Header(node))
        XCTAssertEqual(header.currentPageIndex, 1)
        XCTAssertEqual(header.lastPageIndex, 498)
    }

    func testHeaderWithLastPageIndex() throws {
        let testPaginator = """
            <span class="pg-jump-menu"><a class="menu-root" href="#pg-jump">Страница</a> :  </span>
            <a class="pg" href="">Прев.</a>
            <a class="pg" href="">1</a>,
            <b>2</b>
            """
        let node = ForumPage.Header.xmlFixture(pageIndices: testPaginator)
        let header = try XCTUnwrap(ForumPage.Header(node))
        XCTAssertEqual(header.currentPageIndex, 2)
        XCTAssertEqual(header.lastPageIndex, 2)
    }

    func testHeaderWithMiddlePageIndex() throws {
        let testPaginator = """
            <span class="pg-jump-menu"><a class="menu-root" href="#pg-jump">Страница</a> :  </span>
            <a class="pg" href="">Пред.</a>
            <a class="pg" href="">1</a>,
            <a class="pg" href="">2</a>,
            <b>3</b>,
            <a class="pg" href="">4</a> ...
            <a class="pg" href="">72</a>,
            <a class="pg" href="">73</a>,
            <a class="pg" href="">74</a>
            <a class="pg" href="">След.</a>
            """
        let node = ForumPage.Header.xmlFixture(pageIndices: testPaginator)
        let header = try XCTUnwrap(ForumPage.Header(node))
        XCTAssertEqual(header.currentPageIndex, 3)
        XCTAssertEqual(header.lastPageIndex, 74)
    }
}
