//
//  ServerConnecting.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 24.01.2022.
//

import Foundation
import Combine
import DomainPrimitives



protocol ServerConnecting
{
    func fetchForumCatalog() -> AnyPublisher<Catalog, FetchingError>
    func fetchTopics(from forumId: ForumId, modifiedAfter earlyDate: Date) -> AnyPublisher<[Topic], FetchingError>
}


#if DEBUG
struct ForumCatalogFetcherStub: ServerConnecting
{
    func fetchForumCatalog() -> AnyPublisher<Catalog, FetchingError> {
        return Future{ $0(.success(CatalogStub.preview)) }
            .delay(for: 0.5, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func fetchTopics(from forumId: ForumId, modifiedAfter earlyDate: Date) -> AnyPublisher<[Topic], FetchingError> {
        return Future{ $0(.success(TopicStub.preview)) }
            .delay(for: 0.5, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
#endif
