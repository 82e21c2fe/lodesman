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
    var id: ForumId { get }
    var title: ForumTitle { get }
    var section: ForumTitle { get }
    var lastUpdate: Date? { get }
    var updationState: UpdationState { get }
    var numberOfTopics: Int { get }
}


#if DEBUG
final class ForumStub: Forum, Identifiable, ObservableObject
{
    var id: ForumId
    var title: ForumTitle
    var section: ForumTitle
    var lastUpdate: Date?
    var updationState: UpdationState
    var numberOfTopics: Int

    init(id: ForumId? = nil,
         title: ForumTitle? = nil,
         section: ForumTitle? = nil,
         lastUpdate: Date? = nil,
         updationState: UpdationState? = nil,
         numberOfTopics: Int? = nil)
    {
        self.id = id ?? ForumId(rawValue: Int.max)!
        self.title = title ?? "Untitled"
        self.section = section ?? "Untitled"
        self.lastUpdate = lastUpdate
        self.updationState = updationState ?? .success
        self.numberOfTopics = numberOfTopics ?? 12_345
    }

    static let preview = "alpha beta gamma zeta"
        .components(separatedBy: " ")
        .enumerated()
        .map{ (index, title) in
            ForumStub(id: ForumId(rawValue: index + 1)!,
                      title: ForumTitle(rawValue: title)!,
                      numberOfTopics: index * 9_876)
        }
}
#endif
