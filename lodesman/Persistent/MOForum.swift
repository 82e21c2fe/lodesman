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
    @NSManaged var id: Int
    @NSManaged var title: String
    @NSManaged var section: String
    @NSManaged var lastUpdate: Date?
    @NSManaged var state_: String?
    @NSManaged var topics: Set<MOTopic>
}


extension MOForum: Forum
{
    var forumId: ForumId {
        return ForumId(rawValue: id)!
    }

    var numberOfTopics: Int {
        return topics.count
    }

    var state: UpdationState? {
        get { UpdationState(rawValue: state_ ?? "") }
        set { state_ = newValue?.rawValue }
    }
}


extension MOForum
{
    static func with(forumId id: ForumId, context: NSManagedObjectContext) -> MOForum
    {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.rawValue as NSNumber)
        guard let result = try? context.fetch(request).first
        else {
            let result = MOForum(context: context)
            result.id = id.rawValue
            return result
        }
        return result
    }

    static func allWith(forumIds: Set<ForumId>, context: NSManagedObjectContext) -> [MOForum]
    {
        let request = MOForum.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", forumIds.map(\.rawValue) as CVarArg)
        return (try? context.fetch(request)) ?? []
    }

    @nonobjc static func fetchRequest() -> NSFetchRequest<MOForum> {
        return NSFetchRequest<MOForum>(entityName: "Forum")
    }
}
