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

        let topicStore: TopicStore
        let forumStore: ForumStore
        let fetcher: ServerConnecting

        init(persistent: Persistent, fetcher: ServerConnecting) {
            self.topicStore = persistent.topicStore
            self.forumStore = persistent.forumStore
            self.fetcher = fetcher
        }

        //MARK: -
        func subscribe(to items: [ForumInfo]) {
            forumStore.insert(forums: items)
            updateForums()
        }

        //MARK: -
        private func updateForums() {
            let needUpdate = forumStore.forums.filter({ ($0.lastUpdate ?? .distantPast).timeIntervalSinceNow < -3600 })

            for (index, forum) in needUpdate.enumerated() {
                forumStore.setUpdationState(forForum: forum.id, to: .waiting)
                queue.asyncAfter(deadline: .now().advanced(by: .seconds(5 * index))) { [weak self] in
                    self?.updateForum(from: forum.id, modifiedAfter: forum.lastUpdate ?? .distantPast)
                }
            }
        }

        private func updateForum(from forumId: ForumId, modifiedAfter earlyDate: Date) {
            guard jobs.index(forKey: forumId) == nil else { return }
            DispatchQueue.main.async {
                self.forumStore.setUpdationState(forForum: forumId, to: .loading)
            }
            let job = fetcher.fetchTopics(from: forumId, modifiedAfter: earlyDate)
                .map(\.topics)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    defer {self?.jobs.removeValue(forKey: forumId)}
                    switch completion {
                    case .finished:
                        self?.forumStore.setUpdationState(forForum: forumId, to: .success)
                    case .failure(let error):
                        print("\(error.localizedDescription)")
                        self?.forumStore.setUpdationState(forForum: forumId, to: .failure)
                    }
                } receiveValue: { [weak self] topics in
                    var items = topics
                    let index = items.partition(by: { $0.status == .consumed })
                    let normal = Array(items[..<index])
                    let consumed = Set(items[index...].map(\.topicId))

                    self?.topicStore.insert(topics: normal, toForum: forumId)
                    self?.topicStore.remove(topics: consumed)
                }
            jobs[forumId] = job
        }

        private var queue = DispatchQueue(label: "ee.82e21c2fe.lodesman.network", qos: .utility)
        private var jobs = [ForumId: AnyCancellable]()
    }
}
