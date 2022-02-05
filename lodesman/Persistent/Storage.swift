//
//  Storage.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 30.01.2022.
//

import Foundation
import CoreData



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
    var forums: [Forum] {
        let request = MOForum.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MOForum.section, ascending: true),
                                   NSSortDescriptor(keyPath: \MOForum.title, ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    func insert(forums items: [(section: String, forumId: Int, title: String)]) {
        objectWillChange.send()
        for item in items {
            let forum = MOForum.with(forumId: item.forumId, context: context)
            forum.title = item.title
            forum.section = item.section
        }

        try? context.save()
    }

    func remove(forums forumIds: Set<Int>) {
        objectWillChange.send()
        let result = MOForum.allWith(forumIds: forumIds, context: context)
        result.forEach { context.delete($0) }

        try? context.save()
    }

    func setLastUpdate(forForum forumId: Int) {
        objectWillChange.send()
        let result = MOForum.with(forumId: forumId, context: context)
        result.objectWillChange.send()
        result.lastUpdate = Date()

        try? context.save()
    }

    func setState(forForum forumId: Int, state: UpdationState?) {
        objectWillChange.send()
        let result = MOForum.with(forumId: forumId, context: context)
        result.objectWillChange.send()
        result.state = state
    }
}


//MARK: - Adopt TopicStorage

extension Storage: TopicStorage
{
    func insert(topics items: [Topic], toForum forumId: Int) {
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

    func topic(withId topicId: Int) -> Topic? {
        return MOTopic.with(topicId: topicId, context: context)
    }

    func togglePin(forTopics topicIds: Set<Int>) {
        objectWillChange.send()
        let topics = MOTopic.allWith(topicIds: topicIds, context: context)
        for topic in topics {
            topic.pinned.toggle()
        }

        try? context.save()
    }

    func topics(withIds topicIds: Set<Int>) -> [Topic] {
        return MOTopic.allWith(topicIds: topicIds, context: context)
    }

    func topics(fromForums forumIds: Set<Int>, whereTitleContains text: String, sortedBy: TopicSortOrder) -> [Topic] {
        let request = MOTopic.fetchRequest()

        var fmt = "forum.forumId IN %@"
        var args: [Any] = [forumIds]
        if !text.isEmpty {
            fmt += " AND title CONTAINS[CD] %@"
            args.append(text as NSString)
        }
        request.predicate = NSPredicate(format: fmt, argumentArray: args)

        var sortDescriptors = [NSSortDescriptor(keyPath: \MOTopic.pinned, ascending: false),
                               NSSortDescriptor(keyPath: \MOTopic.title, ascending: true)]
        if sortedBy == .byLastUpdate {
            sortDescriptors.insert(NSSortDescriptor(keyPath: \MOTopic.lastUpdate, ascending: false), at: 1)
        }
        request.sortDescriptors = sortDescriptors

        return (try? context.fetch(request)) ?? []
    }
}
