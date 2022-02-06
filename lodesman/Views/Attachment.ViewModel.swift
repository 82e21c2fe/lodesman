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

        init(_ attachment: Attachment) {
            precondition(0 <= attachment.size)

            self.contentSize = sizeFmt.string(from: Measurement(value: Double(attachment.size),
                                                                unit: .gigabytes))
        }
    }
}


fileprivate let sizeFmt: ByteCountFormatter = {
    let result = ByteCountFormatter()
    result.countStyle = .file
    return result
}()
