//
//  Content.ViewModel.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 02.02.2022.
//

import SwiftUI
import Combine



extension ContentView
{
    final class ViewModel: ObservableObject
    {
        @Published var showForumCatalog = false
        @Published var selectedForums = Set<Int>()
        @Published var selectedTopics = Set<Int>()

        @ObservedObject var storage: Storage
        let fetcher: ServerConnection

        init(storage: Storage, fetcher: ServerConnection) {
            self.storage = storage
            self.fetcher = fetcher
            updateForums()
        }

        //MARK: -
        func subscribe(to items: [CatalogItem]) {
            storage.insertForums(fromCatalog: items)
            updateForums()
        }

        //MARK: -
        private func updateForums() {
            let needUpdate = storage.forums.filter({ ($0.lastUpdate ?? .distantPast).timeIntervalSinceNow < -3600 })

            for (index, forum) in needUpdate.enumerated() {
                queue.asyncAfter(deadline: .now().advanced(by: .seconds(5 * index))) { [weak self] in
                    self?.updateForum(from: forum.forumId, modifiedAfter: forum.lastUpdate ?? .distantPast)
                }
            }
        }

        private func updateForum(from forumId: Int, modifiedAfter earlyDate: Date) {
            guard jobs.index(forKey: forumId) == nil else { return }
            let job = fetcher.fetchTopics(from: forumId, modifiedAfter: earlyDate)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    defer {self?.jobs.removeValue(forKey: forumId)}
                    switch completion {
                    case .finished:
                        self?.storage.setLastUpdate(forForum: forumId)
                    case .failure(let error):
                        print("\(error.localizedDescription)")
                    }
                } receiveValue: { [weak self] topics in
                    self?.storage.insert(topics: topics)
                }
            jobs[forumId] = job
        }

        private var queue = DispatchQueue(label: "ee.82e21c2fe.lodesman.network", qos: .utility)
        private var jobs = [Int: AnyCancellable]()
    }
}
