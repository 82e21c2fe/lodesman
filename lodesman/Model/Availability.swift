//
//  Availability.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 06.02.2022.
//

import Foundation



/// Content availability from 0 to 5 points.
struct Availability: RawRepresentable, Equatable, Hashable
{
    let rawValue: Int16

    init?(rawValue value: Int16 = 0) {
        guard Availability.isValid(value) else { return nil }
        self.rawValue = value
    }

    init?(numberOfSeeders seeders: Int) {
        guard 0 <= seeders else { return nil }

        let availability = min(5, log(Float(seeders + 1)).rounded(.up))

        self.init(rawValue: Int16(availability))
    }

    private static func isValid(_ value: Int16) -> Bool {
        return (0...5).contains(value)
    }
}


//MARK: - Adopts `Comparable` protocol

extension Availability: Comparable
{
    static func < (lhs: Availability, rhs: Availability) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}


//MARK: - Adopts `ExpressibleByIntegerLiteral` protocol
#if DEBUG
extension Availability: ExpressibleByIntegerLiteral
{
    init(integerLiteral value: Int16) {
        precondition(Availability.isValid(value))
        self.rawValue = value
    }
}
#endif
