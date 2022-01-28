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
    func topics(fromForums: Set<Int>, whereTitleContains text: String, sortedBy: TopicSortOrder) -> [Topic]
    func togglePin(forTopics topicIds: Set<Int>)
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

    private var topics = TopicStub.preview
}
#endif
