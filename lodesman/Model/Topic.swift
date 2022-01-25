//
//  Topic.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 25.01.2022.
//

import Foundation



enum TopicStatus: String
{
    case approved
    case duplicate
    case consumed
}


protocol Topic
{
    var topicId: Int { get }
    var title: String { get }
    var status: TopicStatus { get }

    /// Estimated content size in gigabytes.
    var contentSize: Float { get }

    /// Content availability from 0 to 5 points.
    var availability: Int { get }

    var lastUpdate: Date { get }
    var pinned: Bool { get }
}


#if DEBUG
struct TopicStub: Topic
{
    var topicId: Int = 1
    var pinned: Bool = false
    var title: String = "untitled"
    var status: TopicStatus = .approved
    var contentSize: Float = 34.5
    var availability: Int = 5
    var lastUpdate: Date = Date()

    static let preview = [
        TopicStub(topicId: 3, title: "first topic", lastUpdate: Date(timeIntervalSinceNow: -100_000)),
        TopicStub(topicId: 2, pinned: true, title: "second topic", lastUpdate: Date(timeIntervalSinceNow: -50_000)),
        TopicStub(topicId: 7, status: .duplicate, availability: 1),
        TopicStub(topicId: 5, status: .consumed, contentSize: 0.45, availability: 3)
    ]
}
#endif
