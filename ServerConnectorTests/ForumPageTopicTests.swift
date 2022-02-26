//
//  ForumPageTopicTests.swift
//  ServerConnectorTests
//
//  Created by Dmitri Shuvalov on 01.02.2022.
//

import XCTest
import DomainPrimitives
@testable import ServerConnector


extension TopicStatus
{
    var xmlCode: String {
        switch self {
        case .unknown:      return "tor-not-approved"
        case .approved:     return "tor-approved"
        case .duplicate:    return "tor-dup"
        case .consumed:     return "tor-consumed"
        case .closed:       return "tor-closed"
        }
    }
}

extension ForumPage.Topic
{
    static func xmlFixture(id: String = "22",
                           status: String = TopicStatus.approved.xmlCode,
                           title: String = "title",
                           seeds: String = "2",
                           size: String = "79.1 GB",
                           date: String = "2019-12-15 20:33") -> XMLElement
    {
        let info = status == TopicStatus.consumed.xmlCode
                || status == TopicStatus.closed.xmlCode ? " " : """
                <td><div>
                    <div><span class="seedmed"><b>\(seeds)</b></span></div>
                    <div class="small"><a href="">\(size)</a></div>
                </div></td>
            """
        let test = """
            <tr data-topic_id="\(id)">
                <td><div class="torTopic">
                    <span class="tor-icon \(status)">x</span>
                    <a href="">\(title)</a>
                </div></td>
                \(info)
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
    func testTopicWithNonIntegerSeedmed() throws {
        let node = ForumPage.Topic.xmlFixture(seeds: "test")
        XCTAssertNil(ForumPage.Topic(node))
    }

    func testTopicWithZeroSeedmed() throws {
        let node = ForumPage.Topic.xmlFixture(seeds: "0")
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssertEqual(topic.availability, 0)
    }

    func testTopicWithTwoSeed() throws {
        let node = ForumPage.Topic.xmlFixture(seeds: "2")
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssertEqual(topic.availability, 2)
    }

    func testTopicWithHundredSeeds() throws {
        let node = ForumPage.Topic.xmlFixture(seeds: "100")
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssertEqual(topic.availability, 5)
    }

    //MARK: - content size
    func testTopicWithEmptySize() throws {
        let node = ForumPage.Topic.xmlFixture(size: "")
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssertEqual(topic.contentSize, 0)
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
        let status = TopicStatus.approved
        let node = ForumPage.Topic.xmlFixture(status: status.xmlCode)
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssertEqual(topic.status, status)
    }

    func testTopicWithStatusDuplication() throws {
        let status = TopicStatus.duplicate
        let node = ForumPage.Topic.xmlFixture(status: status.xmlCode)
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssertEqual(topic.status, status)
    }

    func testTopicWithStatusConsumed() throws {
        let status = TopicStatus.consumed
        let node = ForumPage.Topic.xmlFixture(id: "117", status: status.xmlCode)
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssertEqual(topic.status, status)
        XCTAssertEqual(topic.topicId, 117)
        XCTAssertEqual(topic.contentSize, 0)
        XCTAssertEqual(topic.availability, 0)
    }

    func testTopicWithStatusClosed() throws {
        let status = TopicStatus.closed
        let node = ForumPage.Topic.xmlFixture(id: "117", status: status.xmlCode)
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssertEqual(topic.status, status)
        XCTAssertEqual(topic.topicId, 117)
        XCTAssertEqual(topic.contentSize, 0)
        XCTAssertEqual(topic.availability, 0)
    }


    func testTopicWithStatusUnknown() throws {
        let status = TopicStatus.unknown
        let node = ForumPage.Topic.xmlFixture(status: status.xmlCode)
        let topic = try XCTUnwrap(ForumPage.Topic(node))
        XCTAssertEqual(topic.status, status)
    }

    func testTopicWithEmptyStatus() throws {
        let node = ForumPage.Topic.xmlFixture(status: "")
        XCTAssertNil(ForumPage.Topic(node))
    }
}
