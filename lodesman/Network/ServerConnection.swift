//
//  ServerConnection.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 29.01.2022.
//

import Foundation
import Combine



struct ServerConnection: ForumCatalogFetching
{
    private let fetcher: NetworkFetching
    private let baseURL: URL

    init?(hostname: String, fetcher: NetworkFetching = URLSession.shared) {
        guard !hostname.isEmpty
            , let url = URL(string: "https://\(hostname)/forum/")
        else {
            return nil
        }
        self.baseURL = url
        self.fetcher = fetcher
    }

    func fetchForumCatalog() -> AnyPublisher<Catalog, FetchingError> {
        let url = URL(string: "index.php?map", relativeTo: baseURL)!

        return fetcher.load(URLRequest(url: url))
            .tryMap { try CatalogPage(data: $0) }
            .mapError { $0 as? FetchingError ?? .unknown }
            .eraseToAnyPublisher()
    }
}


extension ForumPage.Topic: Topic, Attachment
{
    // Topic
    var synopsis: String? { nil }
    var attachment: Attachment? { self }
    var pinned: Bool { false }
    // Attachment
    var link: URL? { nil }
    var size: Float { contentSize }
}


extension ServerConnection: TopicFetching
{
    func fetchTopics(from forumId: Int, modifiedAfter earlyDate: Date) -> AnyPublisher<[Topic], FetchingError> {
        let isDone = PassthroughSubject<Void, Never>()
        return NetworkScheduler.pageIndexPublisher
            .flatMap { (index: Int) -> AnyPublisher<ForumPage, FetchingError>  in
                fetchForumPage(forumId: forumId, pageIndex: index)
                    .retry(2)
                    .eraseToAnyPublisher()
            }
            .prefix(while: { page in !page.topics.isEmpty && earlyDate < page.lastUpdate })
            .prefix(untilOutputFrom: isDone)
            .handleEvents(receiveOutput: { page in
                if page.header.currentPageIndex == page.header.lastPageIndex {
                    isDone.send()
                }
            })
            .map({$0.topics})
            .eraseToAnyPublisher()
    }

    func fetchForumPage(forumId: Int, pageIndex: Int) -> AnyPublisher<ForumPage, FetchingError> {
        let url = URL(string: "viewforum.php?f=\(forumId)&start=\(pageIndex * 50)", relativeTo: baseURL)!

        return fetcher.load(URLRequest(url: url))
            .tryMap { try ForumPage(data: $0) }
            .mapError { $0 as? FetchingError ?? .unknown }
            .eraseToAnyPublisher()
    }

}


struct NetworkScheduler {
    private static let timer = Timer.publish(every: 1, tolerance: 0.3, on: .main, in: .default)
        .autoconnect()
        .share()

    private static func timeRamp(_ val: Int) -> Int {
        return val <= 10 ? val : 10 + val / 10
    }

    static var pageIndexPublisher: AnyPublisher<Int, Never> {
        let jitter = Double.random(in: 0.1 ... 0.5)

        return NetworkScheduler.timer
            .delay(for: .seconds(jitter), tolerance: .seconds(0.1), scheduler: RunLoop.main)
            .scan(0) { acc, _ in acc + 1 }
            .prepend(0)
            .map(NetworkScheduler.timeRamp)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
