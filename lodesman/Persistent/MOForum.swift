//
//  MOForum.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 27.01.2022.
//

import Foundation
import CoreData
import DomainPrimitives



@objc(MOForum) final class MOForum: NSManagedObject
{
    @NSManaged private var externalId: Int
    @NSManaged private var title_: String
    @NSManaged private var section_: String
    @NSManaged private var lastUpdate_: Date?
    @NSManaged private var updationState_: String?
    @NSManaged private var topics: Set<MOTopic>
}


extension MOForum: Forum, Identifiable
{
    var id: ForumId {
        return ForumId(rawValue: externalId)!
    }

    var title: ForumTitle {
        get { ForumTitle(rawValue: title_) ?? "Untitled" }
        set { title_ = newValue.rawValue }
    }

    var section: ForumTitle {
        get { ForumTitle(rawValue: section_) ?? "Untitled" }
        set { section_ = newValue.rawValue }
    }

    var numberOfTopics: Int {
        return topics.count
    }

    var updationState: UpdationState {
        get { UpdationState(rawValue: updationState_ ?? "") ?? .success }
        set {
            if newValue == .success {
                lastUpdate_ = Date()
            }
            updationState_ = newValue.rawValue
        }
    }

    var lastUpdate: Date? {
        return lastUpdate_
    }
}


extension MOForum
{
    func update(from other: ForumInfo) {
        precondition(self.id == other.id)

        objectWillChange.send()
        self.title = other.title
        self.section = other.section
    }

    static func with(forumId id: ForumId, context: NSManagedObjectContext) -> MOForum
    {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "externalId == %@", id.rawValue as NSNumber)
        guard let result = try? context.fetch(request).first
        else {
            let result = MOForum(context: context)
            result.externalId = id.rawValue
            return result
        }
        return result
    }

    static func allWith(forumIds: Set<ForumId>, context: NSManagedObjectContext) -> [MOForum]
    {
        let request = MOForum.fetchRequest()
        request.predicate = NSPredicate(format: "externalId IN %@", forumIds.map(\.rawValue) as CVarArg)
        return (try? context.fetch(request)) ?? []
    }

    @nonobjc static func fetchRequest() -> NSFetchRequest<MOForum> {
        let request = NSFetchRequest<MOForum>(entityName: "Forum")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MOForum.section_, ascending: true),
                                   NSSortDescriptor(keyPath: \MOForum.title_, ascending: true)]
        return request
    }
}
