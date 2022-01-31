//
//  MOAttachment.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 27.01.2022.
//

import Foundation
import CoreData



@objc(MOAttachment) final class MOAttachment: NSManagedObject
{
    @NSManaged var link: URL?
    @NSManaged var size: Float
    @NSManaged var availability_: Int16
    @NSManaged var topic: MOTopic!
}


extension MOAttachment: Attachment
{
    var availability: Int {
        get { Int(availability_) }
        set { availability_ = Int16(newValue) }
    }
}
