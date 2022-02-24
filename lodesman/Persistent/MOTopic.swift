//
//  MOTopic.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 30.01.2022.
//

import Foundation
import CoreData
import DomainPrimitives



@objc(MOTopic) final class MOTopic: NSManagedObject
{
    @NSManaged private var externalId: Int
    @NSManaged private var title_: String
    @NSManaged private var status_: String
    @NSManaged private var contentSize_: Float
    @NSManaged private var availability_: Int16
    @NSManaged var lastUpdate: Date
    @NSManaged var link: URL?
    @NSManaged var synopsis: String?
    @NSManaged var pinned: Bool
    @NSManaged var forum: MOForum!
}


extension MOTopic: Topic, Identifiable
{
    var id: TopicId {
        return TopicId(rawValue: externalId)!
    }

    var title: TopicTitle {
        get { return TopicTitle(rawValue: title_) ?? "Untitled" }
        set { title_ = newValue.rawValue }
    }

    var status: TopicStatus {
        get { TopicStatus(rawValue: status_) ?? .consumed }
        set { status_ = newValue.rawValue }
    }

    var contentSize: ContentSize {
        get { ContentSize(rawValue: contentSize_) ?? 0 }
        set { contentSize_ = newValue.rawValue }
    }

    var availability: Availability {
        get { Availability(rawValue: availability_) ?? 0 }
        set { availability_ = newValue.rawValue }
    }
}


extension MOTopic
{
    func update(from other: TopicInfo) {
        precondition(self.id == other.topicId)

        objectWillChange.send()
        self.title = other.title
        self.status = other.status
        self.lastUpdate = other.lastUpdate
        self.contentSize = other.contentSize
        self.availability = other.availability
    }

    static func with(topicId id: TopicId, context: NSManagedObjectContext) -> MOTopic {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "externalId == %@", id.rawValue as NSNumber)
        guard let result = try? context.fetch(request).first
        else {
            let result = MOTopic(context: context)
            result.externalId = id.rawValue
            return result
        }
        return result
    }

    static func allWith(topicIds: Set<TopicId>, context: NSManagedObjectContext) -> [MOTopic]
    {
        let request = MOTopic.fetchRequest()
        request.predicate = NSPredicate(format: "externalId IN %@", topicIds.map(\.rawValue) as CVarArg)
        return (try? context.fetch(request)) ?? []
    }


    @nonobjc static func fetchRequest() -> NSFetchRequest<MOTopic> {
        return NSFetchRequest<MOTopic>(entityName: "Topic")
    }

    static func sortDescriptors(_ sortedBy: TopicSortOrder) -> [NSSortDescriptor] {
        var sortDescriptors = [NSSortDescriptor(keyPath: \MOTopic.pinned, ascending: false),
                               NSSortDescriptor(keyPath: \MOTopic.title_, ascending: true)]
        if sortedBy == .byLastUpdate {
            sortDescriptors.insert(NSSortDescriptor(keyPath: \MOTopic.lastUpdate, ascending: false), at: 1)
        }
        return sortDescriptors
    }
}
