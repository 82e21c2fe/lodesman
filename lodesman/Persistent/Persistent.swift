//
//  Persistent.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 27.01.2022.
//

import Foundation
import CoreData



struct Persistent
{
    static let shared = Persistent()

    let container: NSPersistentContainer
    let forumStore: ForumStore
    let topicStore: TopicStore


    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "lodesman")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        forumStore = ForumStore(context: container.viewContext)
        topicStore = TopicStore(context: container.viewContext)
    }
}

