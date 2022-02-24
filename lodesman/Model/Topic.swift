//
//  Topic.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 25.01.2022.
//

import Foundation
import DomainPrimitives



protocol Topic
{
    var id: TopicId { get }
    var status: TopicStatus { get }
    var title: TopicTitle { get }
    var contentSize: ContentSize { get }
    var availability: Availability { get }
    var lastUpdate: Date { get }
    var link: URL? { get }
    var synopsis: String? { get }
    var pinned: Bool { get }
}


#if DEBUG
final class TopicStub: Topic, ObservableObject, Identifiable
{
    var id: TopicId
    var status: TopicStatus
    var title: TopicTitle
    var contentSize: ContentSize
    var availability: Availability
    var lastUpdate: Date
    var link: URL?
    var synopsis: String?
    var pinned: Bool

    init(id: TopicId? = nil,
         status: TopicStatus? = nil,
         title: TopicTitle? = nil,
         contentSize: ContentSize? = nil,
         availability: Availability? = nil,
         lastUpdate: Date? = nil,
         link: URL? = URL(string: "https://example.home.arpa/bigfile.dat"),
         synopsis: String? = TopicStub.synopsis,
         pinned: Bool? = nil)
    {
        self.id = id ?? 1
        self.status = status ?? .approved
        self.title = title ?? "Untitled"
        self.contentSize = contentSize ?? 12.5
        self.availability = availability ?? 5
        self.lastUpdate = lastUpdate ?? Date()
        self.link = link
        self.synopsis = synopsis
        self.pinned = pinned ?? false
    }

    static let preview = [
        TopicStub(id: 3,
                  title: "first topic",
                  contentSize: 0.45,
                  availability: 3,
                  lastUpdate: Date(timeIntervalSinceNow: -100_000)),
        TopicStub(id: 2,
                  title: "second topic",
                  contentSize: 0.00045,
                  availability: 3,
                  lastUpdate: Date(timeIntervalSinceNow: -50_000),
                  synopsis: "",
                  pinned: true),
        TopicStub(id: 7, status: .duplicate, availability: 1),
        TopicStub(id: 5, status: .consumed)
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
