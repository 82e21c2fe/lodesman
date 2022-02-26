//
//  TopicStatus.swift
//  DomainPrimitives
//
//  Created by Dmitri Shuvalov on 13.02.2022.
//

import Foundation



public enum TopicStatus: String
{
    case unknown
    case approved
    case duplicate
    case consumed
    case closed
}
