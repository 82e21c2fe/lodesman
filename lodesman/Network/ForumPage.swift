//
//  ForumPage.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 31.01.2022.
//

import Foundation



struct ForumPage
{
    var forumId: Int
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
        var topicId: Int
        var title: String
        var status: TopicStatus
        var contentSize: Double?
        var availability: Int
        var lastUpdate: Date
    }

    var lastUpdate: Date {
        return topics.map(\.lastUpdate).max() ?? Date.distantPast
    }
}


extension ForumPage
{
    init(data: Data) throws {
        do {
            let text = String(data: data, encoding: .windowsCP1251)!
            let document = try XMLDocument(xmlString: text, options: [.documentTidyXML,
                                                                      .nodeLoadExternalEntitiesNever])

            guard let header = try document.nodes(forXPath: XPathNames.header).compactMap({ Header($0) }).first
                , header.href.hasPrefix("viewforum.php?f=")
                , let forumId = Int(header.href.dropFirst(16))
                , 0 < forumId
            else {
                throw FetchingError.parsing
            }

            let topics = try document.nodes(forXPath: XPathNames.topic)
                .compactMap({ Topic($0) })

            self.init(forumId: forumId, header: header, topics: topics)
        }
        catch {
            throw FetchingError.parsing
        }
    }
}


extension ForumPage.Header
{
    init?(_ node: XMLNode) {
        guard let maintitleNode = try? node.nodes(forXPath: XPathNames.maintitle).first as? XMLElement
            , let title = maintitleNode.textValue
            , (1...256).contains(title.count)
            , let href = maintitleNode.attribute(forName: "href")?.textValue
            , let indicesNode = try? node.nodes(forXPath: XPathNames.indices).first as? XMLElement
        else {
            return nil
        }
        let description = try? node.nodes(forXPath: XPathNames.description).first?.textValue
        let currentPage = (try? indicesNode.nodes(forXPath: XPathNames.currentPage)
                            .compactMap({ Int($0.textValue!) })
                            .first) ?? 1
        let lastPage = (try? indicesNode.nodes(forXPath: XPathNames.lastPage)
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
    guard let text = try? node.nodes(forXPath: XPathNames.status).first?.textValue
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
    return nil
}

fileprivate func getId(fromTopic node: XMLNode) -> Int?
{
    guard let text = try? node.nodes(forXPath: XPathNames.topicId).first?.stringValue
        , let id = Int(text)
        , 0 < id
    else {
        return nil
    }
    return id
}

fileprivate func getTitle(fromTopic node: XMLNode) -> String?
{
    guard let title = try? node.nodes(forXPath: XPathNames.topicTitle).first?.textValue
        , (1...256).contains(title.count)
    else {
        return nil
    }
    return title
}

fileprivate func getAvailability(fromTopic node: XMLNode) -> Int?
{
    guard let text = try? node.nodes(forXPath: XPathNames.seedmed).first?.textValue
        , let seeders = Int(text)
        , 0 < seeders
    else {
        return nil
    }
    let availability = Int(log(Float(seeders)).rounded(.up))

    return min(availability, 5)
}

fileprivate func getContentSize(fromTopic node: XMLNode) -> Double?
{
    guard let text = try? node.nodes(forXPath: XPathNames.contentSize).first?.textValue
    else {
        return nil
    }

    let components = text.components(separatedBy: .whitespacesAndNewlines).filter({ !$0.isEmpty })
    guard components.count == 2
        , let value = Double(components[0])
        , let scale = ["kb", "mb", "gb", "tb"].firstIndex(of: components[1].lowercased())
        , 0 < value && value.isFinite && !value.isNaN
    else {
        return nil
    }

    return value * pow(1000, Double(scale) - 2)
}

fileprivate let timestampFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.dateFormat = "yyyy-MM-dd HH:mm"
    return fmt
}()


fileprivate func getLastUpdate(fromTopic node: XMLNode) -> Date?
{
    return try? node.nodes(forXPath: XPathNames.lastUpdate)
        .compactMap { $0.textValue }
        .compactMap(timestampFormatter.date(from:))
        .first
}


//MARK: -

fileprivate struct XPathNames
{
    //Header
    static let header = "//table[@class='w100']/tr/td"
    static let maintitle = "./h1[@class='maintitle']/a"
    static let description = "./div[@class='forum-desc-in-title']"
    static let indices = "./div[@class='small']/b"
    static let currentPage = "./b"
    static let lastPage = "./a[@class='pg']"

    //Topic
    static let topic = "//tr[@data-topic_id]"
    static let topicId = "./@data-topic_id"
    static let status = "./td/div[@class='torTopic']/span/@class"
    static let topicTitle = "./td/div[@class='torTopic']/a[text()]"
    static let seedmed = "./td/div/div/span[@class='seedmed']"
    static let contentSize = "./td/div/div/a[text()]"
    static let lastUpdate = "./td/p[text()]"
}
