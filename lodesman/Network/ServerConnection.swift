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
