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
    //MARK: - Availability
    func testAttachmentWithAvailabilityZeroPoint() throws {
        let attachment = AttachmentStub(availability: 0)
        let model = AttachmentView.ViewModel(attachment)
        XCTAssertEqual(model.availability, "")
    }

    func testAttachmentWithAvailabilityOnePoint() throws {
        let attachment = AttachmentStub(availability: 1)
        let model = AttachmentView.ViewModel(attachment)
        XCTAssertEqual(model.availability, "✦")
    }

    func testAttachmentWithAvailabilityFivePoint() throws {
        let attachment = AttachmentStub(availability: 5)
        let model = AttachmentView.ViewModel(attachment)
        XCTAssertEqual(model.availability, "✦✦✦✦✦")
    }

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
