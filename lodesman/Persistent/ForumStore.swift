//
//  ForumStore.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 23.02.2022.
//

import Foundation
import CoreData
import DomainPrimitives



final class ForumStore: ForumStoring, ObservableObject
{
    init(context: NSManagedObjectContext) {
        self.context = context
    }

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
        let result = MOForum.with(forumId: forumId, context: context)
        result.objectWillChange.send()
        result.updationState = to
        if to == .success {
            try? context.save()
        }
    }

    private let context: NSManagedObjectContext
}
