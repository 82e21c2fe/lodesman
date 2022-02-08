//
//  ForumPage.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 31.01.2022.
//

import Foundation



struct ForumPage
{
    var header: Header
    var topics: [ForumPage.Topic]

    struct Header
    {
        var href: String
        var title: String
        var description: String?
        var currentPageIndex: Int
        var lastPageIndex: Int
    }

    struct Topic
    {
        var topicId: TopicId
        var title: TopicTitle
        var status: TopicStatus
        var contentSize: ContentSize
        var availability: Availability
        var lastUpdate: Date
    }

    var lastUpdate: Date {
        return topics.map(\.lastUpdate).max() ?? Date.distantPast
    }

    var isLastPage: Bool {
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
                throw FetchingError.parsing
            }

            let document = try XMLDocument(xmlString: text, options: [.documentTidyHTML,
                                                                      .nodePreserveAll,
                                                                      .nodeLoadExternalEntitiesNever])
            let topics = try document.nodes(forXPath: XPathName.topic)
                .compactMap({ ForumPage.Topic($0) })

            self.init(header: header, topics: topics)
        }
        catch {
            throw FetchingError.parsing
        }
    }
}


extension ForumPage.Header
{
    init?(_ xmlString: String) {
        guard let document = try? XMLDocument(xmlString: xmlString, options: [.documentTidyXML,
                                                                        .nodeLoadExternalEntitiesNever])
            , let maintitleNode = try? document.nodes(forXPath: XPathName.maintitle).first as? XMLElement
            , let title = maintitleNode.textValue
            , (1...256).contains(title.count)
            , let href = maintitleNode.attribute(forName: "href")?.textValue
        else {
            return nil
        }
        let description = try? document.nodes(forXPath: XPathName.description).first?.textValue

        let currentPage = (try? document.nodes(forXPath: XPathName.currentPage)
                            .compactMap({ Int($0.textValue!) })
                            .first) ?? 1
        let lastPage = (try? document.nodes(forXPath: XPathName.otherPage)
                            .compactMap({ Int($0.textValue!) })
                            .sorted()
                            .last) ?? 1

        self.init(href: href,
                  title: title,
                  description: description?.isEmpty == false ? description : nil,
                  currentPageIndex: currentPage,
                  lastPageIndex: max(currentPage, lastPage))
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

fileprivate func getStatus(fromTopic node: XMLNode) -> TopicStatus?
{
    guard let text = try? node.nodes(forXPath: XPathName.status).first?.textValue
    else {
        return nil
    }

    if text.contains("tor-approved") {
        return .approved
    }
    else if text.contains("tor-dup") {
        return .duplicate
    }
    else if text.contains("tor-consumed") {
        return .consumed
    }
    else if text.contains("tor-not-approved") {
        return .unknown
    }
    else if text.contains("tor-need-edit") {
        return .unknown
    }
    else {
        print("WARNING: the topic has an unexpected status '\(text)'.")
    }
    return .unknown
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
        return nil
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
        .compactMap(timestampFormatter.date(from:))
        .first
}


//MARK: -

fileprivate struct XPathName
{
    // Header
    static let maintitle = "//h1[@class='maintitle']/a"
    static let description = "//div[@class='forum-desc-in-title']"
    static let currentPage = "//span[@class='pg-jump-menu']/../b"
    static let otherPage = "//span[@class='pg-jump-menu']/../a[@class='pg']"

    // Topic
    static let topic = "//tr[@data-topic_id]"
    static let topicId = "./@data-topic_id"
    static let status = "./td/div[@class='torTopic']/span/@class"
    static let topicTitle = "./td/div[@class='torTopic']/a[text()]"
    static let seedmed = "./td/div/div/span[@class='seedmed']"
    static let contentSize = "./td/div/div/a[text()]"
    static let lastUpdate = "./td/p[text()]"
}
