//
//  ForumStorage.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 28.01.2022.
//

import Foundation
import DomainPrimitives


struct ForumInfo
{
    var id: ForumId
    var title: ForumTitle
    var section: ForumTitle
}


protocol ForumStorage: ObservableObject
{
    var forums: [Forum] { get }
    func insert(forums items: [ForumInfo])
    func remove(forums forumIds: Set<ForumId>)
    func setUpdationState(forForum forumId: ForumId, to: UpdationState)
}


#if DEBUG
final class ForumStorageStub: ForumStorage
{
    private(set) var forums: [Forum] = ForumStub.preview

    func insert(forums items: [ForumInfo]) { assert(false) }
    func remove(forums forumIds: Set<ForumId>) { assert(false) }
    func setUpdationState(forForum forumId: ForumId, to: UpdationState) { assert(false) }
}
#endif
