//
//  NetworkScheduler.swift
//  ServerConnector
//
//  Created by Dmitri Shuvalov on 13.02.2022.
//

import Foundation
import Combine


struct NetworkScheduler {
    private static let timer = Timer.publish(every: 1, tolerance: 0.3, on: .main, in: .default)
        .autoconnect()
        .share()

    private static func timeRamp(_ val: Int) -> Int {
        return val <= 10 ? val : 10 + val / 10
    }

    static var pageIndexPublisher: AnyPublisher<PageIndex, Never> {
        let jitter = Double.random(in: 0.1 ... 0.5)

        return NetworkScheduler.timer
            .delay(for: .seconds(jitter), tolerance: .seconds(0.1), scheduler: RunLoop.main)
            .scan(0) { acc, _ in acc + 1 }
            .map(NetworkScheduler.timeRamp)
            .prefix(while: { $0 <= PageIndex.last.rawValue })
            .removeDuplicates()
            .map({ PageIndex(rawValue: $0)! })
            .eraseToAnyPublisher()
    }
}
