//
//  TopicId.swift
//  DomainPrimitives
//
//  Created by Dmitri Shuvalov on 07.02.2022.
//

import Foundation



public struct TopicId: RawRepresentable, Equatable, Hashable
{
    public let rawValue: Int

    public init?(rawValue value: Int) {
        guard TopicId.isValid(value) else { return nil }
        self.rawValue = value
    }

    private static func isValid(_ value: Int) -> Bool {
        return 0 < value
    }
}


//MARK: - Adopts `LosslessStringConvertible` protocol

extension TopicId: LosslessStringConvertible
{
    public init?(_ text: String) {
        guard !text.isEmpty
            , text.count < 20
            , let _ = text.range(of: #"^\d+$"#, options: [.regularExpression])
            , let value = Int(text)
        else { return nil }
        self.init(rawValue: value)
    }

    public var description: String {
        return "\(rawValue)"
    }
}


//MARK: - Adopts `ExpressibleByIntegerLiteral` protocol
#if DEBUG
extension TopicId: ExpressibleByIntegerLiteral
{
    public init(integerLiteral value: Int) {
        precondition(TopicId.isValid(value))
        self.rawValue = value
    }
}
#endif
