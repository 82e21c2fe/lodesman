//
//  Attachment.ViewModel.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 26.01.2022.
//

import Foundation



extension AttachmentView
{
    struct ViewModel
    {
        let contentSize: String
        let availability: String

        init(_ attachment: Attachment) {
            precondition(0 <= attachment.size)
            precondition((0...5).contains(attachment.availability))

            self.contentSize = sizeFmt.string(from: Measurement(value: Double(attachment.size),
                                                                unit: .gigabytes))
            self.availability = repeatElement("✦", count: attachment.availability).joined()
        }
    }
}


fileprivate let sizeFmt: ByteCountFormatter = {
    let result = ByteCountFormatter()
    result.countStyle = .file
    return result
}()
