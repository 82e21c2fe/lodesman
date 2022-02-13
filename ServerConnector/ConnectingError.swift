//
//  ConnectingError.swift
//  ServerConnector
//
//  Created by Dmitri Shuvalov on 24.01.2022.
//

import Foundation



public enum ConnectingError: Error, CustomStringConvertible
{
    case network
    case parsing
    case unknown

    public var description: String {
        switch self {
        case .network: return "Request to Server failed"
        case .parsing: return "Failed parsing response from server"
        case .unknown: return "An unknown error occurred"
        }
    }
}
