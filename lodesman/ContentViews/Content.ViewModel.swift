//
//  Content.ViewModel.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 02.02.2022.
//

import SwiftUI
import Combine
import DomainPrimitives


extension ContentView
{
    final class ViewModel: ObservableObject
    {
        @Published var showForumCatalog = false
        @Published var selectedForums = Set<ForumId>()
        @Published var selectedTopics = Set<TopicId>()

        @ObservedObject var storage: Storage
        let fetcher: ServerConnecting

        init(storage: Storage, fetcher: ServerConnecting) {
            self.storage = storage
            self.fetcher = fetcher
        }

        //MARK: -
        func subscribe(to items: [(section: ForumTitle, forumId: ForumId, title: ForumTitle)]) {
            storage.insert(forums: items)
            updateForums()
        }

        //MARK: -
        private func updateForums() {
            let needUpdate = storage.forums.filter({ ($0.lastUpdate ?? .distantPast).timeIntervalSinceNow < -3600 })

            for (index, forum) in needUpdate.enumerated() {
                storage.setState(forForum: forum.forumId, state: .waiting)
                queue.asyncAfter(deadline: .now().advanced(by: .seconds(5 * index))) { [weak self] in
                    self?.updateForum(from: forum.forumId, modifiedAfter: forum.lastUpdate ?? .distantPast)
                }
            }
        }

        private func updateForum(from forumId: ForumId, modifiedAfter earlyDate: Date) {
            guard jobs.index(forKey: forumId) == nil else { return }
            DispatchQueue.main.async {
                self.storage.setState(forForum: forumId, state: .loading)
            }
            let job = fetcher.fetchTopics(from: forumId, modifiedAfter: earlyDate)
                .map(\.topics)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    defer {self?.jobs.removeValue(forKey: forumId)}
                    switch completion {
                    case .finished:
                        self?.storage.setLastUpdate(forForum: forumId)
                        self?.storage.setState(forForum: forumId, state: .success)
                    case .failure(let error):
                        print("\(error.localizedDescription)")
                        self?.storage.setState(forForum: forumId, state: .failure)
                    }
                } receiveValue: { [weak self] topics in
                    var items = topics
                    let index = items.partition(by: { $0.status == .consumed })
                    let normal = Array(items[..<index])
                    let consumed = Set(items[index...].map(\.topicId))

                    self?.storage.insert(topics: normal, toForum: forumId)
                    self?.storage.remove(topics: consumed)
                }
            jobs[forumId] = job
        }

        private var queue = DispatchQueue(label: "ee.82e21c2fe.lodesman.network", qos: .utility)
        private var jobs = [ForumId: AnyCancellable]()
    }
}
