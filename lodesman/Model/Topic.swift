//
//  Topic.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 25.01.2022.
//

import Foundation



enum TopicStatus: String
{
    case unknown
    case approved
    case duplicate
    case consumed
}


protocol Attachment
{
    var link: URL? { get }
    var size: ContentSize { get }
    var availability: Availability { get }
}


protocol Topic
{
    var topicId: TopicId { get }
    var status: TopicStatus { get }
    var title: TopicTitle { get }
    var synopsis: String? { get }
    var attachment: Attachment? { get }
    var lastUpdate: Date { get }
    var pinned: Bool { get }
}


#if DEBUG
struct AttachmentStub: Attachment
{
    var link: URL? = URL(string: "https://example.home.arpa/bigfile.dat")!
    var size: ContentSize = 12.5
    var availability: Availability = 5
}

struct TopicStub: Topic
{
    var topicId: TopicId = 1
    var status: TopicStatus = .approved
    var title: TopicTitle = "untitled"
    var synopsis: String? = TopicStub.synopsis
    var attachment: Attachment?
    var lastUpdate: Date = Date()
    var pinned: Bool = false

    static let preview = [
        TopicStub(topicId: 3,
                  title: "first topic",
                  attachment: AttachmentStub(size: 0.45, availability: 3),
                  lastUpdate: Date(timeIntervalSinceNow: -100_000)),
        TopicStub(topicId: 2,
                  title: "second topic",
                  synopsis: "",
                  attachment: AttachmentStub(size: 0.00045, availability: 3),
                  lastUpdate: Date(timeIntervalSinceNow: -50_000),
                  pinned: true),
        TopicStub(topicId: 7, status: .duplicate, attachment: AttachmentStub(availability: 1)),
        TopicStub(topicId: 5, status: .consumed)
    ]

    static let synopsis = """
        <h1>Lorem ipsum...</h1>
        <p>Lorem ipsum dolor sit amet, consectetur adipisci elit, sed eiusmod tempor incidunt ut labore
           et dolore magna aliqua. Ut enim ad minim veniam, quis nostrum exercitationem ullam corporis
           suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur. Quis aute iure reprehenderit
           in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint obcaecat
           cupiditat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
        </p>
        """
}
#endif
