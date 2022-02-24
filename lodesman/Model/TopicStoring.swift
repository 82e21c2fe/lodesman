//
//  TopicStoring.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 28.01.2022.
//

import Foundation
import DomainPrimitives



enum TopicSortOrder: CaseIterable, Identifiable
{
    case byLastUpdate, byTitle

    var id: Self { return self }
}


protocol TopicInfo
{
    var topicId: TopicId { get }
    var title: TopicTitle { get }
    var status: TopicStatus { get }
    var lastUpdate: Date { get }
    var contentSize: ContentSize { get }
    var availability: Availability { get }
}


protocol TopicStoring: ObservableObject
{
    associatedtype Item: Topic & ObservableObject & Identifiable

    func topic(withId topicId: TopicId) -> Item?
    func topics(fromForums: Set<ForumId>, whereTitleContains text: String, sortedBy: TopicSortOrder) -> [Item]
    func togglePin(forTopics topicIds: Set<TopicId>)
    func insert(topics items: [TopicInfo], toForum forumId: ForumId)
    func remove(topics topicIds: Set<TopicId>)
}


#if DEBUG
final class TopicStorageStub: TopicStoring
{
    func topic(withId topicId: TopicId) -> TopicStub? {
        return TopicStub.preview.first
    }
    func topics(fromForums: Set<ForumId>, whereTitleContains text: String, sortedBy: TopicSortOrder) -> [TopicStub] {
        return TopicStub.preview
    }
    func togglePin(forTopics topicIds: Set<TopicId>) { assert(false) }
    func insert(topics items: [TopicInfo], toForum: ForumId) { assert(false) }
    func remove(topics topicIds: Set<TopicId>) { assert(false) }
}
#endif
