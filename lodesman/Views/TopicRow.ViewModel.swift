//
//  TopicRow.ViewModel.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 25.01.2022.
//

import SwiftUI



extension TopicRow
{
    struct ViewModel
    {
        let title: String
        let contentSize: String
        let availability: String
        let status: TopicStatus
        let pinned: Bool

        init(_ topic: Topic) {
            precondition(!topic.title.isEmpty)
            precondition(0 <= topic.contentSize)
            precondition((0...5).contains(topic.availability))

            self.title = topic.title
            self.contentSize = sizeFmt.string(from: Measurement(value: Double(topic.contentSize),
                                                                unit: .gigabytes))
            self.availability = repeatElement("✦", count: topic.availability).joined()
            self.status = topic.status
            self.pinned = topic.pinned
        }
    }
}


fileprivate let sizeFmt: ByteCountFormatter = {
    let result = ByteCountFormatter()
    result.countStyle = .file
    return result
}()
