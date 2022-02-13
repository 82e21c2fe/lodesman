//
//  ContentSize.swift
//  DomainPrimitives
//
//  Created by Dmitri Shuvalov on 06.02.2022.
//

import Foundation


/// Estimated content size in gigabytes.
public struct ContentSize: RawRepresentable, Equatable, Hashable
{
    public let rawValue: Float

    public init?(rawValue value: Float) {
        guard ContentSize.isValid(value) else { return nil }
        self.rawValue = value
    }

    public init?(_ text: String) {
        guard !text.isEmpty
            , text.count < 16
            , let _ = text.range(of: #"^\d+(\.\d+)?\s+[KMGT]B$"#, options: [.regularExpression, .caseInsensitive])
        else {
            return nil
        }

        let components = text.components(separatedBy: .whitespacesAndNewlines).filter({ !$0.isEmpty })
        guard components.count == 2
            , let value = Double(components[0])
            , let unit = ContentSize.units[components[1]]
        else {
            return nil
        }

        let temp = Measurement(value: value, unit: unit).converted(to: .gigabytes).value

        self.init(rawValue: Float(temp))
    }

    public var measurement: Measurement<UnitInformationStorage> {
        return Measurement(value: Double(rawValue), unit: .gigabytes)
    }

    private static func isValid(_ value: Float) -> Bool {
        return (0...1_024).contains(value)
    }

    private static var units: [String: UnitInformationStorage] = [
        "KB": .kilobytes,
        "MB": .megabytes,
        "GB": .gigabytes,
        "TB": .terabytes
    ]
}



//MARK: - Adopts `Comparable` protocol

extension ContentSize: Comparable
{
    public static func < (lhs: ContentSize, rhs: ContentSize) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

//MARK: - Adopts `ExpressibleByFloatLiteral` and `ExpressibleByIntegerLiteral` protocols
#if DEBUG
extension ContentSize: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral
{
    public init(floatLiteral value: Float) {
        precondition(ContentSize.isValid(value))
        self.rawValue = value
    }

    public init(integerLiteral value: Int) {
        let value = Float(value)
        precondition(ContentSize.isValid(value))
        self.rawValue = value
    }
}
#endif
