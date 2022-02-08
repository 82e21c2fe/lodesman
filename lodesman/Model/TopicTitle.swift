//
//  TopicTitle.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 08.02.2022.
//

import Foundation



struct TopicTitle: RawRepresentable, Equatable, Hashable
{
    let rawValue: String

    init?(rawValue value: String) {
        let value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard TopicTitle.isValid(value) else { return nil }
        self.rawValue = value
    }

    var firstLetter: String {
        var level = 0
        for character in rawValue {
            switch Symbol(character) {
            case .alphanumeric where 0 == level: return character.uppercased()
            case .openBracket:  level += 1
            case .closeBracket: level -= 1
            default: break
            }
        }
        return "-"
    }

    private enum Symbol
    {
        case alphanumeric
        case openBracket
        case closeBracket
        case other

        init(_ value: String.Element) {
            if value.isNumber || value.isLetter {
                self = .alphanumeric
            }
            else if "([<{".contains(value) {
                self = .openBracket
            }
            else if ")]>}".contains(value) {
                self = .closeBracket
            }
            else {
                self = .other
            }
        }
    }

    private static func isValid(_ value: String) -> Bool {
        return (2...256).contains(value.count)
    }
}


//MARK: - Adopts `Comparable` protocol

extension TopicTitle: Comparable
{
    static func < (lhs: TopicTitle, rhs: TopicTitle) -> Bool {
        return lhs.rawValue.localizedStandardCompare(rhs.rawValue) == .orderedAscending
    }
}


//MARK: - Adopts `ExpressibleByStringLiteral` protocol
#if DEBUG
extension TopicTitle: ExpressibleByStringLiteral
{
    init(stringLiteral value: StringLiteralType) {
        precondition(TopicTitle.isValid(value))
        self.rawValue = value
    }
}
#endif
