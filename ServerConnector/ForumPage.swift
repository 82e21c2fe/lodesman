//
//  ForumPage.swift
//  ServerConnector
//
//  Created by Dmitri Shuvalov on 31.01.2022.
//

import Foundation
import DomainPrimitives



public struct ForumPage
{
    public var header: ForumPage.Header
    public var topics: [ForumPage.Topic]

    public struct Topic
    {
        public var topicId: TopicId
        public var title: TopicTitle
        public var status: TopicStatus
        public var contentSize: ContentSize
        public var availability: Availability
        public var lastUpdate: Date
    }

    public var lastUpdate: Date {
        return topics.map(\.lastUpdate).max() ?? Date.distantPast
    }

    public var isLastPage: Bool {
        return header.currentPageIndex == header.lastPageIndex
    }
}


extension ForumPage
{
    init(data: Data) throws {
        do {
            let text = String(data: data, encoding: .windowsCP1251)!

            guard let header = ForumPage.Header(text)
            else {
                throw ConnectingError.parsing
            }

            let document = try XMLDocument(xmlString: text, options: [.documentTidyHTML,
                                                                      .nodePreserveAll,
                                                                      .nodeLoadExternalEntitiesNever])
            let topics = try document.nodes(forXPath: XPathName.topic)
                .compactMap({ ForumPage.Topic($0) })

            self.init(header: header, topics: topics)
        }
        catch {
            throw ConnectingError.parsing
        }
    }
}


extension ForumPage.Topic
{
    init?(_ node: XMLNode) {
        guard let availability = getAvailability(fromTopic: node)
            , let id = getId(fromTopic: node)
            , let title = getTitle(fromTopic: node)
            , let status = getStatus(fromTopic: node)
            , let size = getContentSize(fromTopic: node)
            , let lastUpdate = getLastUpdate(fromTopic: node)
        else {
            return nil
        }
        self.init(topicId: id,
                  title: title,
                  status: status,
                  contentSize: size,
                  availability: availability,
                  lastUpdate: lastUpdate)
    }
}

extension TopicStatus
{
    fileprivate init?(_ text: String) {
        guard (14...32).contains(text.count)
            , let _ = text.range(of: #"^tor-icon\s+tor-[-a-z]+$"#, options: .regularExpression)
        else {
            return nil
        }

        if text.contains("tor-approved")            { self = .approved }
        else if text.contains("tor-dup")            { self = .duplicate }
        else if text.contains("tor-consumed")       { self = .consumed }
        else if text.contains("tor-not-approved")   { self = .unknown }
        else if text.contains("tor-need-edit")      { self = .unknown }
        else                                        { self = .unknown }
    }
}

fileprivate func getStatus(fromTopic node: XMLNode) -> TopicStatus?
{
    guard let text = try? node.nodes(forXPath: XPathName.status).first?.textValue
    else {
        return nil
    }
    return TopicStatus(text)
}

fileprivate func getId(fromTopic node: XMLNode) -> TopicId?
{
    guard let text = try? node.nodes(forXPath: XPathName.topicId).first?.stringValue
    else {
        return nil
    }
    return TopicId(text)
}

fileprivate func getTitle(fromTopic node: XMLNode) -> TopicTitle?
{
    guard let title = try? node.nodes(forXPath: XPathName.topicTitle).first?.textValue
    else {
        return nil
    }
    return TopicTitle(rawValue: title)
}

fileprivate func getAvailability(fromTopic node: XMLNode) -> Availability?
{
    guard let text = try? node.nodes(forXPath: XPathName.seedmed).first?.textValue
    else {
        return Availability(rawValue: 0)
    }
    guard (1...16).contains(text.count)
        , let _ = text.range(of: #"\d+"#, options: .regularExpression)
        , let seeders = Int(text)
    else {
        return nil
    }
    return Availability(numberOfSeeders: seeders)
}

fileprivate func getContentSize(fromTopic node: XMLNode) -> ContentSize?
{
    guard let text = try? node.nodes(forXPath: XPathName.contentSize).first?.textValue
    else {
        return ContentSize(rawValue: 0)
    }
    return ContentSize(text)
}

fileprivate let timestampFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.dateFormat = "yyyy-MM-dd HH:mm"
    return fmt
}()


fileprivate func getLastUpdate(fromTopic node: XMLNode) -> Date?
{
    return try? node.nodes(forXPath: XPathName.lastUpdate)
        .compactMap { $0.textValue }
        .filter({ $0.count == 16 })
        .compactMap(timestampFormatter.date(from:))
        .first
}


//MARK: -

fileprivate struct XPathName
{
    static let topic = "//tr[@data-topic_id]"
    static let topicId = "./@data-topic_id"
    static let status = "./td/div[@class='torTopic']/span/@class"
    static let topicTitle = "./td/div[@class='torTopic']/a[text()]"
    static let seedmed = "./td/div/div/span[@class='seedmed']"
    static let contentSize = "./td/div/div/a[text()]"
    static let lastUpdate = "./td/p[text()]"
}
