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
    func insert(forums items: [(section: ForumTitle, forumId: ForumId, title: ForumTitle)])
    func remove(forums forumIds: Set<ForumId>)
    func setLastUpdate(forForum forumId: ForumId)
    func setState(forForum forumId: ForumId, state: UpdationState?)
}


#if DEBUG
final class ForumStorageStub: ForumStorage
{
    private(set) var forums: [Forum] = ForumStub.preview

    func insert(forums items: [(section: ForumTitle, forumId: ForumId, title: ForumTitle)]) { assert(false) }
    func remove(forums forumIds: Set<ForumId>) { assert(false) }
    func setLastUpdate(forForum forumId: ForumId) { assert(false) }
    func setState(forForum forumId: ForumId, state: UpdationState?) { assert(false) }
}
#endif
