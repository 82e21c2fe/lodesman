//
//  TopicStorage.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 28.01.2022.
//

import Foundation



enum TopicSortOrder: CaseIterable, Identifiable
{
    case byLastUpdate, byTitle

    var id: Self { return self }
}


protocol TopicStorage: ObservableObject
{
    func topic(withId topicId: Int) -> Topic?
    func topics(fromForums: Set<Int>, whereTitleContains text: String, sortedBy: TopicSortOrder) -> [Topic]
    func togglePin(forTopics topicIds: Set<Int>)
    func insert(topics items: [Topic], toForum forumId: Int)
}


#if DEBUG
extension TopicSortOrder
{
    var comparator: (TopicStub, TopicStub) -> Bool {
        switch self {
        case .byLastUpdate: return { lhs, rhs in lhs.lastUpdate > rhs.lastUpdate }
        case .byTitle:      return { lhs, rhs in lhs.title.localizedStandardContains(rhs.title) }
        }
    }
}

final class TopicStorageStub: TopicStorage
{
    func topic(withId topicId: Int) -> Topic? {
        return topics.first(where: { $0.topicId == topicId })
    }

    func topics(fromForums: Set<Int>, whereTitleContains text: String, sortedBy: TopicSortOrder) -> [Topic] {
        let result = !text.isEmpty ? topics.filter({ $0.title.localizedStandardContains(text) }) : topics
        return result.sorted(by: sortedBy.comparator)
    }

    func togglePin(forTopics topicIds: Set<Int>) {
        objectWillChange.send()
        for topicId in topicIds {
            guard let index = topics.firstIndex(where: { $0.topicId == topicId }) else { continue }
            topics[index].pinned.toggle()
        }
    }

    func insert(topics items: [Topic], toForum: Int) {
        objectWillChange.send()
        for item in items {
            if let index = topics.firstIndex(where: { $0.topicId == item.topicId }) {
                topics[index] = TopicStub(item)
            } else {
                topics.append(TopicStub(item))
            }
        }
    }

    private var topics = TopicStub.preview
}

extension TopicStub
{
    init(_ other: Topic) {
        self.init(topicId: other.topicId,
                  status: other.status,
                  title: other.title,
                  synopsis: other.synopsis,
                  attachment: AttachmentStub(other.attachment),
                  lastUpdate: other.lastUpdate,
                  pinned: other.pinned)
    }
}

extension AttachmentStub
{
    init?(_ other: Attachment?) {
        guard let other = other else {
            return nil
        }
        self.init(link: other.link, size: other.size, availability: other.availability)
    }
}
#endif
