//
//  TopicStore.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 30.01.2022.
//

import Foundation
import CoreData
import DomainPrimitives



final class TopicStore: TopicStoring, ObservableObject
{
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func insert(topics items: [TopicInfo], toForum forumId: ForumId) {
        objectWillChange.send()
        let forum = MOForum.with(forumId: forumId, context: context)
        forum.objectWillChange.send()
        for item in items {
            let temp = MOTopic.with(topicId: item.topicId, context: context)
            temp.update(from: item)
            temp.forum = forum
        }

        try? context.save()
    }

    func remove(topics topicIds: Set<TopicId>) {
        objectWillChange.send()
        let result = MOTopic.allWith(topicIds: topicIds, context: context)
        result.forEach { context.delete($0) }

        try? context.save()
    }

    func topic(withId topicId: TopicId) -> MOTopic? {
        return MOTopic.with(topicId: topicId, context: context)
    }

    func togglePin(forTopics topicIds: Set<TopicId>) {
        objectWillChange.send()
        let topics = MOTopic.allWith(topicIds: topicIds, context: context)
        for topic in topics {
            topic.objectWillChange.send()
            topic.pinned.toggle()
        }

        try? context.save()
    }

    func topics(withIds topicIds: Set<TopicId>) -> [MOTopic] {
        return MOTopic.allWith(topicIds: topicIds, context: context)
    }

    func topics(fromForums forumIds: Set<ForumId>,
                whereTitleContains text: String,
                sortedBy: TopicSortOrder) -> [MOTopic]
    {
        let request = MOTopic.fetchRequest()

        var fmt = "forum.externalId IN %@"
        var args: [Any] = [forumIds.map(\.rawValue)]
        if !text.isEmpty {
            fmt += " AND title_ CONTAINS[CD] %@"
            args.append(text as NSString)
        }
        request.predicate = NSPredicate(format: fmt, argumentArray: args)
        request.sortDescriptors = MOTopic.sortDescriptors(sortedBy)

        return (try? context.fetch(request)) ?? []
    }

    private let context: NSManagedObjectContext
}
