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
                XCTFail("Expected to fail receive IndexPage, successed with \(page)")
            }
            .store(in: &cancellable)
        wait(for: [expectation], timeout: 3)
    }
}
