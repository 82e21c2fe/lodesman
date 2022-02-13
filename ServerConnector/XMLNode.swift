//
//  XMLNode.swift
//  ServerConnector
//
//  Created by Dmitri Shuvalov on 29.01.2022.
//

import Foundation


extension XMLNode
{
    var textValue: String? {
        stringValue?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
