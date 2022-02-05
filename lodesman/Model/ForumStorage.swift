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
    func insert(forums items: [(section: String, forumId: Int, title: String)])
    func remove(forums forumIds: Set<Int>)
    func setLastUpdate(forForum forumId: Int)
    func setState(forForum forumId: Int, state: UpdationState?)
}


#if DEBUG
final class ForumStorageStub: ForumStorage
{
    private(set) var forums: [Forum] = ForumStub.preview

    func insert(forums items: [(section: String, forumId: Int, title: String)]) {
        objectWillChange.send()
        for item in items {
            let newValue = ForumStub(forumId: item.forumId, title: item.title, section: item.section)
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
