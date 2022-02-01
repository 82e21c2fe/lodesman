//
//  TopicFetching.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 01.02.2022.
//

import Foundation
import Combine



protocol TopicFetching
{
    func fetchTopics(from forumId: Int, modifiedAfter earlyDate: Date) -> AnyPublisher<[Topic], FetchingError>
}


#if DEBUG
struct TopicFetcherStub: TopicFetching
{
    func fetchTopics(from forumId: Int, modifiedAfter earlyDate: Date) -> AnyPublisher<[Topic], FetchingError> {
        return Future{ $0(.success(TopicStub.preview)) }
            .delay(for: 0.5, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
#endif
