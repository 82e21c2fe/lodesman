//
//  ForumStoring.swift
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


protocol ForumStoring: ObservableObject
{
    associatedtype Item: Forum & ObservableObject & Identifiable

    var forums: [Item] { get }
    func insert(forums items: [ForumInfo])
    func remove(forums forumIds: Set<ForumId>)
    func setUpdationState(forForum forumId: ForumId, to: UpdationState)
}


#if DEBUG
final class ForumStorageStub: ForumStoring
{
    private(set) var forums: [ForumStub] = ForumStub.preview

    func insert(forums items: [ForumInfo]) { assert(false) }
    func remove(forums forumIds: Set<ForumId>) { assert(false) }
    func setUpdationState(forForum forumId: ForumId, to: UpdationState) { assert(false) }
}
#endif
