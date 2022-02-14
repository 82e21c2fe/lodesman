//
//  PageIndex.swift
//  ServerConnector
//
//  Created by Dmitri Shuvalov on 13.02.2022.
//

import Foundation



public struct PageIndex: RawRepresentable, Equatable, Hashable
{
    public let rawValue: Int

    public init?(rawValue value: Int) {
        guard PageIndex.isValid(value) else { return nil }
        self.rawValue = value
    }

    var topicOffset: Int {
        return (rawValue - 1) * PageIndex.numTopicsPerPage
    }

    private static func isValid(_ value: Int) -> Bool {
        return (minValue...maxValue).contains(value)
    }

    public static let first = PageIndex(rawValue: minValue)!
    public static let last = PageIndex(rawValue: maxValue)!

    private static let minValue = 1
    private static let maxValue = 600
    private static let numTopicsPerPage = 50
}


//MARK: - Adopts `Comparable` protocol

extension PageIndex: Comparable
{
    public static func < (lhs: PageIndex, rhs: PageIndex) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}


//MARK: - Adopts `LosslessStringConvertible` protocol

extension PageIndex: LosslessStringConvertible
{
    public init?(_ text: String) {
        guard (1...3).contains(text.count)
            , let _ = text.range(of: #"^\d+$"#, options: .regularExpression)
            , let value = Int(text)
        else { return nil }
        self.init(rawValue: value)
    }

    public var description: String {
        return "\(rawValue)"
    }
}


//MARK: - Adopts `ExpressibleByIntegerLiteral` protocol

extension PageIndex: ExpressibleByIntegerLiteral
{
    public init(integerLiteral value: Int) {
        precondition(PageIndex.isValid(value))
        self.rawValue = value
    }
}
