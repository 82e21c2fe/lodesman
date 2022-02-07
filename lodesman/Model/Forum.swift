//
//  Forum.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 23.01.2022.
//

import Foundation


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
    var title: String { get }
    var section: String { get }
    var lastUpdate: Date? { get set }
    var state: UpdationState? { get set }
    var numberOfTopics: Int { get }
}


#if DEBUG
struct ForumStub: Forum
{
    var forumId: ForumId = 0
    var title: String = "untitled"
    var section: String = ""
    var lastUpdate: Date?
    var state: UpdationState?
    var numberOfTopics: Int = 12_345

    static let preview = "alpha beta gamma zeta"
        .components(separatedBy: " ")
        .enumerated()
        .map{ (index, title) in
            ForumStub(forumId: ForumId(rawValue: index + 1)!, title: title, numberOfTopics: index * 9_876)
        }
}
#endif
