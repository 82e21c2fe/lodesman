//
//  ForumCatalogFetching.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 24.01.2022.
//

import Foundation
import Combine



protocol ForumCatalogFetching
{
    func fetchForumCatalog() -> AnyPublisher<Catalog, FetchingError>
}


#if DEBUG
struct ForumCatalogFecher: ForumCatalogFetching
{
    func fetchForumCatalog() -> AnyPublisher<Catalog, FetchingError> {
        return Future{ $0(.success(CatalogStub.preview)) }
            .delay(for: 0.5, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
#endif
