//
//  ForumPageTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 31.01.2022.
//

import XCTest
@testable import lodesman


extension ForumPage
{
    static func htmlFixture(header: XMLElement = ForumPage.Header.xmlFixture(),
                            topics: [XMLElement] = [ForumPage.Topic.xmlFixture()]) -> Data
    {
        let temp = """
            <!DOCTYPE html>
            <html>
                <head></head>
                <body>
                    <table class="w100">
                        <tr>
                            \(header.xmlString)
                        </tr>
                    </table>
                    <table>
                        \(topics.map(\.xmlString).joined(separator: "\n"))
                    </table>
                </body>
            </html>
            """
        return temp.data(using: .windowsCP1251)!
    }
}


class ForumPageTests: XCTestCase
{
    //MARK: - forum id
    func testEmptyForumId() throws {
        let test = ForumPage.htmlFixture(header: ForumPage.Header.xmlFixture(href: " "))
        XCTAssertThrowsError(try ForumPage(data: test))
    }

    func testZeroForumId() throws {
        let test = ForumPage.htmlFixture(header: ForumPage.Header.xmlFixture(href: "viewforum.php?f=0"))
        XCTAssertThrowsError(try ForumPage(data: test))
    }

    func testNegativeForumId() throws {
        let test = ForumPage.htmlFixture(header: ForumPage.Header.xmlFixture(href: "viewforum.php?f=-12"))
        XCTAssertThrowsError(try ForumPage(data: test))
    }

    func testPositiveForumId() throws {
        let test = ForumPage.htmlFixture(header: ForumPage.Header.xmlFixture(href: "viewforum.php?f=12"))
        let page = try ForumPage(data: test)
        XCTAssertEqual(page.forumId, 12)
    }

    //MARK: - topics
    func testPageWithoutTopics() throws {
        let test = ForumPage.htmlFixture(topics: [])
        let page = try ForumPage(data: test)
        XCTAssertTrue(page.topics.isEmpty)
    }

    func testPageWithOneTopic() throws {
        let test = ForumPage.htmlFixture(topics: [ForumPage.Topic.xmlFixture(id: "10")])
        let page = try ForumPage(data: test)
        XCTAssertEqual(page.topics.count, 1)
        let topic = try XCTUnwrap(page.topics.first)
        XCTAssertEqual(topic.topicId, 10)
    }

    //MARK: - page
    func testPageWithEmptyData() throws {
        XCTAssertThrowsError(try ForumPage(data: Data()))
    }

}
