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


protocol TopicStoring: ObservableObject
{
    func topic(withId topicId: TopicId) -> Topic?
    func topics(fromForums: Set<ForumId>, whereTitleContains text: String, sortedBy: TopicSortOrder) -> [Topic]
    func togglePin(forTopics topicIds: Set<TopicId>)
    func insert(topics items: [Topic], toForum forumId: ForumId)
    func remove(topics topicIds: Set<TopicId>)
}


#if DEBUG
final class TopicStorageStub: TopicStoring
{
    func topic(withId topicId: TopicId) -> Topic? {
        return TopicStub.preview.first
    }
    func topics(fromForums: Set<ForumId>, whereTitleContains text: String, sortedBy: TopicSortOrder) -> [Topic] {
        return TopicStub.preview
    }
    func togglePin(forTopics topicIds: Set<TopicId>) { assert(false) }
    func insert(topics items: [Topic], toForum: ForumId) { assert(false) }
    func remove(topics topicIds: Set<TopicId>) { assert(false) }
}
#endif