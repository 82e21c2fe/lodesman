//
//  ServerConnection.swift
//  ServerConnector
//
//  Created by Dmitri Shuvalov on 29.01.2022.
//

import Foundation
import Combine
import DomainPrimitives



public struct ServerConnection
{
    private let fetcher: NetworkFetching
    private let baseURL: URL

    public init?(hostname: String, fetcher: NetworkFetching = URLSession.shared) {
        guard !hostname.isEmpty
            , let url = URL(string: "https://\(hostname)/forum/")
        else {
            return nil
        }
        self.baseURL = url
        self.fetcher = fetcher
    }

    public func fetchForumCatalog() -> AnyPublisher<CatalogPage, ConnectingError> {
        let url = URL(string: "index.php?map", relativeTo: baseURL)!

        return fetcher.load(URLRequest(url: url))
            .tryMap { try CatalogPage(data: $0) }
            .mapError { $0 as? ConnectingError ?? .unknown }
            .eraseToAnyPublisher()
    }

    public func fetchTopics(from forumId: ForumId, modifiedAfter earlyDate: Date) -> AnyPublisher<ForumPage, ConnectingError> {
        let isDone = PassthroughSubject<Void, Never>()
        return NetworkScheduler.pageIndexPublisher
            .prefix(untilOutputFrom: isDone)
            .flatMap { (index: PageIndex) -> AnyPublisher<ForumPage, ConnectingError>  in
                fetchForumPage(forumId: forumId, pageIndex: index)
                    .retry(2)
                    .eraseToAnyPublisher()
            }
            .prefix(while: { page in !page.topics.isEmpty && earlyDate < page.lastUpdate })
            .handleEvents(receiveOutput: { page in
                if page.isLastPage {
                    isDone.send()
                }
            })
            .eraseToAnyPublisher()
    }

    func fetchForumPage(forumId: ForumId, pageIndex: PageIndex) -> AnyPublisher<ForumPage, ConnectingError> {
        var components = URLComponents(string: "viewforum.php")!
        components.queryItems = [URLQueryItem(name: "f", value: "\(forumId.rawValue)")]
        if pageIndex != .first {
            components.queryItems?.append(URLQueryItem(name: "start", value: "\(pageIndex.topicOffset)"))
        }
        let url = components.url(relativeTo: baseURL)!

        return fetcher.load(URLRequest(url: url))
            .tryMap { try ForumPage(data: $0) }
            .mapError { $0 as? ConnectingError ?? .unknown }
            .eraseToAnyPublisher()
    }
}
