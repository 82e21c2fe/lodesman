//
//  NetworkFetching.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 29.01.2022.
//

import Foundation
import Combine



protocol NetworkFetching
{
    func load(_ request: URLRequest) -> AnyPublisher<Data, FetchingError>
}



extension URLSession: NetworkFetching
{
    func load(_ request: URLRequest) -> AnyPublisher<Data, FetchingError>
    {
        return dataTaskPublisher(for: request)
            .tryMap { (data, response) in
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode
                    , (200...299).contains(statusCode)
                else {
                    throw FetchingError.network
                }
                return data
            }
            .mapError { error -> FetchingError in
                switch error {
                case is URLError: return .network
                case is FetchingError: return error as! FetchingError
                default: return .unknown
                }
            }
            .eraseToAnyPublisher()
    }
}
