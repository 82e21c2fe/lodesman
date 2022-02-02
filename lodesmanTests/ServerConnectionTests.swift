//
//  ServerConnectionTests.swift
//  lodesmanTests
//
//  Created by Dmitri Shuvalov on 29.01.2022.
//

import XCTest
import Combine
@testable import lodesman


fileprivate struct NetworkFetchingStub: NetworkFetching
{
    private let result: Result<Data, FetchingError>
    private let onRequest: (URLRequest) -> Void

    init(returning result: Result<Data, FetchingError>, onRequest: @escaping (URLRequest) -> Void = {_ in}) {
        self.result = result
        self.onRequest = onRequest
    }

    func load(_ request: URLRequest) -> AnyPublisher<Data, FetchingError> {
        onRequest(request)
        return result.publisher
            .delay(for: 0.1, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}


class ServerConnectionTests: XCTestCase
{
    private var cancellable = Set<AnyCancellable>()

    func testServerConnectionWithEmptyHostname() throws {
        let networkStub = NetworkFetchingStub(returning: .failure(.unknown))
        XCTAssertNil(ServerConnection(hostname: "", fetcher: networkStub))
    }

    //MARK: - Catalog page
    func testCatalogPageRequestURL() throws {
        let hostname = "myhost"
        var called = false
        let networkStub = NetworkFetchingStub(returning: .failure(.unknown)) { request in
            XCTAssertEqual(request.url?.absoluteString, "https://\(hostname)/forum/index.php?map")
            called = true
        }
        let fetcher = try XCTUnwrap(ServerConnection(hostname: hostname, fetcher: networkStub))
        _ = fetcher.fetchForumCatalog()
        XCTAssert(called)
    }

    func testCatalogPageRequestSuccess() throws {
        let testData = """
            <!DOCTYPE html>
            <body><div id="f-map">
            <ul class='tree-root'>
                <li><span class='b'><span class="c-title" title="section title"></span></span>
                    <ul><li><span class='b'><a href="638">title of forum 638</a></span></li></ul>
                </li>
            </ul>
            </div></body>
            """.data(using: .windowsCP1251)!
        let networkStub = NetworkFetchingStub(returning: .success(testData))
        let fetcher = try XCTUnwrap(ServerConnection(hostname: "localhost", fetcher: networkStub))
        let expectation = XCTestExpectation(description: "Publishes decoded CatalogPage")
        fetcher.fetchForumCatalog()
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                XCTFail("Expected to success decode CatalogPage, fail with \(error.localizedDescription)")
            } receiveValue: { catalog in
                XCTAssertEqual(catalog.root.count, 1)
                expectation.fulfill()
            }
            .store(in: &cancellable)
        wait(for: [expectation], timeout: 5)
    }

    func testCatalogPageRequestFailure() throws {
        let expectedError = FetchingError.network
        let networkStub = NetworkFetchingStub(returning: .failure(expectedError))
        let fetcher = try XCTUnwrap(ServerConnection(hostname: "localhost", fetcher: networkStub))
        let expectation = XCTestExpectation(description: "Publishes received FetchingError")
        fetcher.fetchForumCatalog()
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                XCTAssertEqual(error, expectedError)
                expectation.fulfill()
            } receiveValue: { page in
                XCTFail("Expected to fail receive CatalogPage, successed with \(page)")
            }
            .store(in: &cancellable)
        wait(for: [expectation], timeout: 3)
    }

    //MARK: - Forum page
    func testForumPageRequestURL() throws {
        let hostname = "myhost"
        var called = false
        let networkStub = NetworkFetchingStub(returning: .failure(.unknown)) { request in
            XCTAssertEqual(request.url?.absoluteString, "https://\(hostname)/forum/viewforum.php?f=12&start=500")
            called = true
        }
        let fetcher = try XCTUnwrap(ServerConnection(hostname: hostname, fetcher: networkStub))
        _ = fetcher.fetchForumPage(forumId: 12, pageIndex: 10)
        XCTAssert(called)
    }

    func testForumPageRequestSuccess() throws {
        let pageIndices = """
            <b>2</b>,
            <a class="pg" href="">3</a> ...
            <a class="pg" href="">36</a>
            <a class="pg" href="">След.</a>
            """
        let testData = ForumPage.htmlFixture(header: ForumPage.Header.xmlFixture(href: "viewforum.php?f=15",
                                                                                 title: "main title",
                                                                                 description: nil,
                                                                                 pageIndices: pageIndices),
                                             topics: [ForumPage.Topic.xmlFixture(id: "00001",
                                                                                 status: .approved,
                                                                                 title: "topic title",
                                                                                 seeds: "2",
                                                                                 size: "79.1 GB",
                                                                                 date: "2019-12-15 20:33")])
        let networkStub = NetworkFetchingStub(returning: .success(testData))
        let fetcher = try XCTUnwrap(ServerConnection(hostname: "hostname", fetcher: networkStub))

        let expectation = XCTestExpectation(description: "Publishes decoded ForumPage")

        fetcher.fetchForumPage(forumId: 15, pageIndex: 1)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                XCTFail("Expected to success decode ForumPage, fail with \(error.localizedDescription)")
            } receiveValue: { page in
                XCTAssertEqual(page.header.currentPageIndex, 2)
                XCTAssertEqual(page.forumId, 15)
                XCTAssertEqual(page.header.lastPageIndex, 36)
                XCTAssertEqual(page.header.title, "main title")
                XCTAssertEqual(page.topics.count, 1)
                XCTAssertEqual(page.topics.first?.title, "topic title")

                expectation.fulfill()
            }
            .store(in: &cancellable)

        wait(for: [expectation], timeout: 5)
    }

    func testForumPageRequestFailure() throws {
        let expectedError = FetchingError.network
        let networkStub = NetworkFetchingStub(returning: .failure(expectedError))
        let fetcher = try XCTUnwrap(ServerConnection(hostname: "hostname", fetcher: networkStub))
        let expectation = XCTestExpectation(description: "Publishes received FetchingError")
        fetcher.fetchForumPage(forumId: 10, pageIndex: 6)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                XCTAssertEqual(error, expectedError)

                expectation.fulfill()
            } receiveValue: { page in
                XCTFail("Expected to fail receive ForumPage, successed with \(page)")
            }
            .store(in: &cancellable)
        wait(for: [expectation], timeout: 3)
    }
}
