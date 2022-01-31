//
//  MOForum.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 27.01.2022.
//

import Foundation
import CoreData



@objc(MOForum) final class MOForum: NSManagedObject
{
    @NSManaged var forumId: Int
    @NSManaged var title: String
    @NSManaged var lastUpdate: Date?
    @NSManaged var topics: Set<MOTopic>
}


extension MOForum: Forum
{
    var numberOfTopics: Int {
        return topics.count
    }
}


extension MOForum
{
    static func with(forumId id: Int, context: NSManagedObjectContext) -> MOForum
    {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "forumId == %@", id as NSNumber)
        guard let result = try? context.fetch(request).first
        else {
            let result = MOForum(context: context)
            result.forumId = id
            return result
        }
        return result
    }

    static func allWith(forumIds: Set<Int>, context: NSManagedObjectContext) -> [MOForum]
    {
        let request = MOForum.fetchRequest()
        request.predicate = NSPredicate(format: "forumId IN %@", forumIds as CVarArg)
        return (try? context.fetch(request)) ?? []
    }

    @nonobjc static func fetchRequest() -> NSFetchRequest<MOForum> {
        return NSFetchRequest<MOForum>(entityName: "Forum")
    }
}
