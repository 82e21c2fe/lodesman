//
//  Forum.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 23.01.2022.
//

import Foundation



protocol Forum
{
    var forumId: Int { get }
    var title: String { get }
    var numberOfTopics: Int { get }
}


#if DEBUG
struct ForumStub: Forum
{
    var forumId: Int = 0
    var title: String = "untitled"
    var numberOfTopics: Int = 12_345

    static let preview = "alpha beta gamma zeta"
        .components(separatedBy: " ")
        .enumerated()
        .map{ (index, title) in
            ForumStub(forumId: index, title: title, numberOfTopics: index * 9_876)
        }
}
#endif
