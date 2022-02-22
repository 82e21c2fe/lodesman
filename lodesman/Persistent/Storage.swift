//
//  Storage.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 30.01.2022.
//

import Foundation
import CoreData
import DomainPrimitives



final class Storage: ObservableObject
{
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }


}

//MARK: - Adopt ForumStorage

extension Storage: ForumStorage
{
    var forums: [MOForum] {
        let request = MOForum.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }

    func insert(forums items: [ForumInfo]) {
        objectWillChange.send()
        for item in items {
            let forum = MOForum.with(forumId: item.id, context: context)
            forum.update(from: item)
        }

        try? context.save()
    }

    func remove(forums forumIds: Set<ForumId>) {
        objectWillChange.send()
        let result = MOForum.allWith(forumIds: forumIds, context: context)
        result.forEach { context.delete($0) }

        try? context.save()
    }

    func setUpdationState(forForum forumId: ForumId, to: UpdationState) {
        objectWillChange.send()
        let result = MOForum.with(forumId: forumId, context: context)
        result.objectWillChange.send()
        result.updationState = to
        if to == .success {
            try? context.save()
        }
    }
}


//MARK: - Adopt TopicStorage

extension Storage: TopicStorage
{
    func insert(topics items: [Topic], toForum forumId: ForumId) {
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

    func topic(withId topicId: TopicId) -> Topic? {
        return MOTopic.with(topicId: topicId, context: context)
    }

    func togglePin(forTopics topicIds: Set<TopicId>) {
        objectWillChange.send()
        let topics = MOTopic.allWith(topicIds: topicIds, context: context)
        for topic in topics {
            topic.pinned.toggle()
        }

        try? context.save()
    }

    func topics(withIds topicIds: Set<TopicId>) -> [Topic] {
        return MOTopic.allWith(topicIds: topicIds, context: context)
    }

    func topics(fromForums forumIds: Set<ForumId>, whereTitleContains text: String, sortedBy: TopicSortOrder) -> [Topic] {
        let request = MOTopic.fetchRequest()

        var fmt = "forum.externalId IN %@"
        var args: [Any] = [forumIds.map(\.rawValue)]
        if !text.isEmpty {
            fmt += " AND title_ CONTAINS[CD] %@"
            args.append(text as NSString)
        }
        request.predicate = NSPredicate(format: fmt, argumentArray: args)

        var sortDescriptors = [NSSortDescriptor(keyPath: \MOTopic.pinned, ascending: false),
                               NSSortDescriptor(keyPath: \MOTopic.title_, ascending: true)]
        if sortedBy == .byLastUpdate {
            sortDescriptors.insert(NSSortDescriptor(keyPath: \MOTopic.lastUpdate, ascending: false), at: 1)
        }
        request.sortDescriptors = sortDescriptors

        return (try? context.fetch(request)) ?? []
    }
}
