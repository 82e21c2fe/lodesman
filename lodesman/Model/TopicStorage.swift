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


protocol TopicStorage
{
    func topics(fromForums: Set<Int>, whereTitleContains text: String, sortedBy: TopicSortOrder) -> [Topic]
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

    private var topics = TopicStub.preview
}
#endif
