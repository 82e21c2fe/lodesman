//
//  UpdationManager.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 22.02.2022.
//

import Foundation
import Combine
import DomainPrimitives
import ServerConnector



final class UpdationManager
{
    private var fetcher: ServerConnecting? {
        guard let hostname = UserDefaults.standard.string(forKey: SettingsKey.hostname)
        else {
            return nil
        }
        return ServerConnection(hostname: hostname)
    }

    private var updateInterval: Double {
        let hours = UserDefaults.standard.double(forKey: SettingsKey.updateInterval)
        guard (4...168).contains(hours) else { return 24 }
        return hours
    }

    init(persistent: Persistent) {
        self.forumStore = persistent.forumStore
        self.topicStore = persistent.topicStore

        Timer.publish(every: 3600, tolerance: 600, on: .main, in: .default)
            .autoconnect()
            .prepend(Date())
            .delay(for: 20, scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                self?.updateForums()
            })
            .store(in: &cancellations)

        self.forumStore.objectWillChange
            .delay(for: 3, scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.updateForums()
            }
            .store(in: &cancellations)
    }

    private func updateForums() {
        let interval = updateInterval * 3600
        let needUpdate = forumStore.forums
            .filter({
                return ($0.lastUpdate ?? .distantPast).timeIntervalSinceNow < -interval
                    && [UpdationState.success, UpdationState.failure].contains($0.updationState)
            })

        for (index, forum) in needUpdate.enumerated() {
            forumStore.setUpdationState(forForum: forum.id, to: .waiting)
            queue.asyncAfter(deadline: .now().advanced(by: .seconds(5 * index))) { [weak self] in
                self?.updateForum(from: forum.id, modifiedAfter: forum.lastUpdate ?? .distantPast)
            }
        }
    }

    private func updateForum(from forumId: ForumId, modifiedAfter earlyDate: Date) {
        guard jobs.index(forKey: forumId) == nil else { return }
        guard let fetcher = fetcher else {
            DispatchQueue.main.async {
                self.forumStore.setUpdationState(forForum: forumId, to: .failure)
            }
            return
        }
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
                let index = items.partition(by: { [.consumed, .closed].contains($0.status) })
                let normal = Array(items[..<index])
                let consumed = Set(items[index...].map(\.topicId))

                self?.topicStore.insert(topics: normal, toForum: forumId)
                self?.topicStore.remove(topics: consumed)
            }
        jobs[forumId] = job
    }

    private var queue = DispatchQueue(label: "ee.82e21c2fe.lodesman.network", qos: .utility)
    private var jobs = [ForumId: AnyCancellable]()
    private var cancellations: Set<AnyCancellable> = []
    private let forumStore: ForumStore
    private let topicStore: TopicStore
}
