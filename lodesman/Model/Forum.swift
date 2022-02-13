//
//  Forum.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 23.01.2022.
//

import Foundation
import DomainPrimitives


enum UpdationState: String
{
    case waiting
    case loading
    case failure
    case success
}


protocol Forum
{
    var forumId: ForumId { get }
    var title: ForumTitle { get }
    var section: ForumTitle { get }
    var lastUpdate: Date? { get set }
    var state: UpdationState? { get set }
    var numberOfTopics: Int { get }
}


#if DEBUG
struct ForumStub: Forum
{
    var forumId: ForumId = ForumId(rawValue: Int.max)!
    var title: ForumTitle = "Untitled"
    var section: ForumTitle = "Untitled"
    var lastUpdate: Date?
    var state: UpdationState?
    var numberOfTopics: Int = 12_345

    static let preview = "alpha beta gamma zeta"
        .components(separatedBy: " ")
        .enumerated()
        .map{ (index, title) in
            ForumStub(forumId: ForumId(rawValue: index + 1)!,
                      title: ForumTitle(rawValue: title)!,
                      numberOfTopics: index * 9_876)
        }
}
#endif
