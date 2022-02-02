//
//  MOTopic.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 30.01.2022.
//

import Foundation
import CoreData



@objc(MOTopic) final class MOTopic: NSManagedObject
{
    @NSManaged var topicId: Int
    @NSManaged var title: String
    @NSManaged var status_: String
    @NSManaged var synopsis: String?
    @NSManaged var lastUpdate: Date
    @NSManaged var pinned: Bool
    @NSManaged var forum: MOForum!
    @NSManaged var attachment_: MOAttachment?
}


extension MOTopic: Topic
{
    var attachment: Attachment? {
        return attachment_
    }
    
    var status: TopicStatus {
        get { TopicStatus(rawValue: status_) ?? .consumed }
        set { status_ = newValue.rawValue }
    }
}


extension MOTopic
{
    func update(from other: Topic) {
        precondition(self.topicId == other.topicId)

        objectWillChange.send()
        self.title = other.title
        self.status = other.status
        self.lastUpdate = other.lastUpdate
        if let synopsis = other.synopsis {
            self.synopsis = synopsis
        }
        if let otherAttachment = other.attachment {
            let attachment = self.attachment_ ?? MOAttachment(context: self.managedObjectContext!)
            attachment.topic = self
            attachment.update(from: otherAttachment)
        }
    }

    static func with(topicId id: Int, context: NSManagedObjectContext) -> MOTopic {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "topicId == %@", id as NSNumber)
        guard let result = try? context.fetch(request).first
        else {
            let result = MOTopic(context: context)
            result.topicId = id
            return result
        }
        return result
    }

    static func allWith(topicIds: Set<Int>, context: NSManagedObjectContext) -> [MOTopic]
    {
        let request = MOTopic.fetchRequest()
        request.predicate = NSPredicate(format: "topicId IN %@", topicIds as CVarArg)
        return (try? context.fetch(request)) ?? []
    }


    @nonobjc static func fetchRequest() -> NSFetchRequest<MOTopic> {
        return NSFetchRequest<MOTopic>(entityName: "Topic")
    }
}
