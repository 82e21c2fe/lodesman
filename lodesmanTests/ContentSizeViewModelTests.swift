//
//  ContentSizeViewModelTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 25.01.2022.
//

import XCTest
@testable import lodesman



class ContentSizeViewModelTests: XCTestCase
{
    func testAttachmentWithContentSizeInGB() throws {
        let model = ContentSizeView.ViewModel(15.2)
        XCTAssertEqual(model.contentSize, "15.2 GB")
    }

    func testAttachmentWithContentSizeInMB() throws {
        let model = ContentSizeView.ViewModel(0.3)
        XCTAssertEqual(model.contentSize, "300 MB")
    }
}
