//
//  ForumTitle.swift
//  DomainPrimitives
//
//  Created by Dmitri Shuvalov on 08.02.2022.
//

import Foundation



public struct ForumTitle: RawRepresentable, Equatable, Hashable
{
    public let rawValue: String

    public init?(rawValue value: String) {
        let value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard ForumTitle.isValid(value) else { return nil }
        self.rawValue = value
    }

    private static func isValid(_ value: String) -> Bool {
        return (2...128).contains(value.count)
    }
}


//MARK: - Adopts `Comparable` protocol
extension ForumTitle: Comparable
{
    public static func < (lhs: ForumTitle, rhs: ForumTitle) -> Bool {
        return lhs.rawValue.localizedStandardCompare(rhs.rawValue) == .orderedAscending
    }
}


//MARK: - Adopts `ExpressibleByStringLiteral` protocol
#if DEBUG
extension ForumTitle: ExpressibleByStringLiteral
{
    public init(stringLiteral value: StringLiteralType) {
        precondition(ForumTitle.isValid(value))
        self.rawValue = value
    }
}
#endif
