//
//  AttachmentViewModelTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 25.01.2022.
//

import XCTest
@testable import lodesman



class AttachmentViewModelTests: XCTestCase
{
    //MARK: - ContentSize
    func testAttachmentWithContentSizeInGB() throws {
        let attachment = AttachmentStub(size: 15.2)
        let model = AttachmentView.ViewModel(attachment)
        XCTAssertEqual(model.contentSize, "15.2 GB")
    }

    func testAttachmentWithContentSizeInMB() throws {
        let attachment = AttachmentStub(size: 0.3)
        let model = AttachmentView.ViewModel(attachment)
        XCTAssertEqual(model.contentSize, "300 MB")
    }
}
