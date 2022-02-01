//
//  ForumPageTopicTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 01.02.2022.
//

import XCTest
@testable import lodesman


extension ForumPage.Topic
{
    enum Status: String
    {
        case approved = "tor-approved"
        case duplication = "tor-dup"
        case consumed = "tor-consumed"
    }

    static func xmlFixture(id: String = "22",
                           status: Status = .approved,
                           title: String = "title",
                           seeds: String = "2",
                           size: String = "79.1 GB",
                           date: String = "2019-12-15 20:33") -> XMLElement
    {
        let test = """
            <tr data-topic_id="\(id)">
                <td><div class="torTopic">
                    <span class="tor-icon \(status.rawValue)"></span>
                    <a href="">\(title)</a>
                </div></td>
                <td><div>
                    <div><span class="seedmed"><b>\(seeds)</b></span></div>
                    <div class="small"><a href="">\(size)</a></div>
                </div></td>
                <td><p>\(date)</p></td>
            </tr>
            """
        return try! XMLElement(xmlString: test)
    }
}


class ForumPageTopicTests: XCTestCase
{
    //MARK: - topicId
    func testTopicWithNonIntegerTopicId() throws {
        let node = ForumPage.Topic.xmlFixture(id: "alpha")
        XCTAssertNil(ForumPage.Topic(node))
    }

    func testTopicWithZeroTopicId() throws {
        let node = ForumPage.Topic.xmlFixture(id: "0")
        XCTAssertNil(ForumPage.Topic(node))
    }

    func testTopicWithPositiveTopicId() throws {
        let node = ForumPage.Topic.xmlFixture(id: "0022")
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssertEqual(topic.topicId, 22)
    }

    //MARK: - title
    func testTopicWithEmptyTitle() throws {
        let node = ForumPage.Topic.xmlFixture(title: " ")
        XCTAssertNil(ForumPage.Topic(node))
    }

    func testTopicWithVeryLongTitle() throws {
        let title = String(repeating: "a", count: 257)
        let node = ForumPage.Topic.xmlFixture(title: title)
        XCTAssertNil(ForumPage.Topic(node))
    }

    func testTopicWithTitle() throws {
        let node = ForumPage.Topic.xmlFixture(title: "subject title")
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssertEqual(topic.title, "subject title")
    }

    //MARK: - availability
    func testTopicWithZeroSeedmed() throws {
        let node = ForumPage.Topic.xmlFixture(seeds: "0")
        XCTAssertNil(ForumPage.Topic(node))
    }

    func testTopicWithTwoSeed() throws {
        let node = ForumPage.Topic.xmlFixture(seeds: "2")
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssertEqual(topic.availability, 1)
    }

    func testTopicWithHundredSeeds() throws {
        let node = ForumPage.Topic.xmlFixture(seeds: "100")
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssertEqual(topic.availability, 5)
    }

    //MARK: - content size
    func testTopicWithEmptySize() throws {
        let node = ForumPage.Topic.xmlFixture(size: "")
        XCTAssertNil(ForumPage.Topic(node))
    }

    func testTopicWithNegativeSize() throws {
        let node = ForumPage.Topic.xmlFixture(size: "-79.1 GB")
        XCTAssertNil(ForumPage.Topic(node))
    }

    func testTopicWithApproximate20GB() throws {
        let node = ForumPage.Topic.xmlFixture(size: "20 GB")
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssertEqual(topic.contentSize, 20)
    }

    func testTopicWithApproximate500MB() throws {
        let node = ForumPage.Topic.xmlFixture(size: "500 MB")
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssertEqual(topic.contentSize, 0.5)
    }

    //MARK: - last update
    func testTopicWithEmptyDate() throws {
        let node = ForumPage.Topic.xmlFixture(date: "")
        XCTAssertNil(ForumPage.Topic(node))
    }

    func testTopicWithDate() throws {
        let node = ForumPage.Topic.xmlFixture(date: "2019-12-15 20:33")
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssert(Calendar.current.date(topic.lastUpdate,
                                        matchesComponents: DateComponents(year: 2019,
                                                                          month: 12,
                                                                          day: 15,
                                                                          hour: 20,
                                                                          minute: 33)))
    }

    //MARK: - status
    func testTopicWithStatusApproved() throws {
        let node = ForumPage.Topic.xmlFixture(status: .approved)
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssertEqual(topic.status, .approved)
    }

    func testTopicWithStatusDuplication() throws {
        let node = ForumPage.Topic.xmlFixture(status: .duplication)
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssertEqual(topic.status, .duplicate)
    }
}
