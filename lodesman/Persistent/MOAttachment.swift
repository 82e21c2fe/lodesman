//
//  MOAttachment.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 27.01.2022.
//

import Foundation
import CoreData
import DomainPrimitives



@objc(MOAttachment) final class MOAttachment: NSManagedObject
{
    @NSManaged var link: URL?
    @NSManaged var size_: Float
    @NSManaged var availability_: Int16
    @NSManaged var topic: MOTopic!
}


extension MOAttachment: Attachment
{
    var size: ContentSize {
        get { ContentSize(rawValue: size_)! }
        set { size_ = newValue.rawValue }
    }

    var availability: Availability {
        get { Availability(rawValue: availability_)! }
        set { availability_ = newValue.rawValue }
    }
}


extension MOAttachment
{
    func update(from other: Attachment) {
        objectWillChange.send()
        self.size = other.size
        self.availability = other.availability
        if let link = other.link {
            self.link = link
        }
    }
}
