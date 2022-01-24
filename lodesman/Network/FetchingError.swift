//
//  FetchingError.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 24.01.2022.
//

import Foundation



enum FetchingError: Error, CustomStringConvertible
{
    case network
    case parsing
    case unknown

    var description: String {
        switch self {
        case .network: return "Request to Server failed"
        case .parsing: return "Failed parsing response from server"
        case .unknown: return "An unknown error occurred"
        }
    }
}
