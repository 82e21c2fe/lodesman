//
//  NetworkFetching.swift
//  ServerConnector
//
//  Created by Dmitri Shuvalov on 29.01.2022.
//

import Foundation
import Combine



public protocol NetworkFetching
{
    func load(_ request: URLRequest) -> AnyPublisher<Data, ConnectingError>
}



extension URLSession: NetworkFetching
{
    public func load(_ request: URLRequest) -> AnyPublisher<Data, ConnectingError>
    {
        return dataTaskPublisher(for: request)
            .tryMap { (data, response) in
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode
                    , (200...299).contains(statusCode)
                    , (50...500_000).contains(data.count)
                else {
                    throw ConnectingError.network
                }
                return data
            }
            .mapError { error -> ConnectingError in
                switch error {
                case is URLError: return .network
                case is ConnectingError: return error as! ConnectingError
                default: return .unknown
                }
            }
            .eraseToAnyPublisher()
    }
}
