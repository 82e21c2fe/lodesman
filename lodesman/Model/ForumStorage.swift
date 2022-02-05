//
//  ForumStorage.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 28.01.2022.
//

import Foundation



protocol ForumStorage: ObservableObject
{
    var forums: [Forum] { get }
    func insert(forums items: [(forumId: Int, title: String)])
    func remove(forums forumIds: Set<Int>)
    func setLastUpdate(forForum forumId: Int)
    func setState(forForum forumId: Int, state: UpdationState?)
}


extension ForumStorage
{
    func insertForums(fromCatalog items: [CatalogItem]) {
        var temp = [Int:String]()
        for item in items {
            if item.kind == .forum {
                temp[item.id] = item.title
            }
            item.forEachChildren { child in
                temp[child.id] = child.title
            }
        }
        let flattenedItems = temp.map({ (forumId: $0.key, title: $0.value) })
        insert(forums: flattenedItems)
    }
}


#if DEBUG
final class ForumStorageStub: ForumStorage
{
    private(set) var forums: [Forum] = ForumStub.preview

    func insert(forums items: [(forumId: Int, title: String)]) {
        objectWillChange.send()
        for item in items {
            let newValue = ForumStub(forumId: item.forumId, title: item.title)
            if let index = forums.firstIndex(where: { $0.forumId == item.forumId }) {
                forums[index] = newValue
            }
            else {
                forums.append(newValue)
            }
        }
    }

    func remove(forums forumIds: Set<Int>) {
        objectWillChange.send()
        forums = forums.filter({ !forumIds.contains($0.forumId) })
    }

    func setLastUpdate(forForum forumId: Int) {
        if let index = forums.firstIndex(where: { $0.forumId == forumId }) {
            forums[index].lastUpdate = Date()
        }
    }

    func setState(forForum forumId: Int, state: UpdationState?) {
        if let index = forums.firstIndex(where: { $0.forumId == forumId }) {
            forums[index].state = state
        }
    }
}
#endif
