//
//  ContentView.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 23.01.2022.
//

import SwiftUI
import DomainPrimitives
import ServerConnector



struct ContentView: View
{
    @AppStorage(SettingsKey.hostname) private var hostname = ""
    @SceneStorage("selectedForums") private var forumIds: String = ""
    @SceneStorage("selectedTopics") private var topicIds: String = ""

    @State private var showForumCatalog = false

    let forumStore: ForumStore
    let topicStore: TopicStore

    var body: some View {
        NavigationView {
            SidebarView(storage: forumStore,
                        selection: selectedForums,
                        showForumCatalog: $showForumCatalog)
            TopicsView(storage: topicStore,
                       forums: selectedForums.wrappedValue,
                       selection: selectedTopics)
        }
        .sheet(isPresented: $showForumCatalog) {
            if let fetcher = ServerConnection(hostname: hostname) {
                ForumCatalogView(fetcher: fetcher) { items in
                    forumStore.insert(forums: items)
                }
            }
        }
    }

    private var selectedForums: Binding<Set<ForumId>> {
        Binding(get: {
            return Set(forumIds.components(separatedBy: ",").compactMap{ ForumId($0) })
        }, set: {
            forumIds = $0.map(\.description).joined(separator: ",")
        })
    }

    private var selectedTopics: Binding<Set<TopicId>> {
        Binding(get: {
            return Set(topicIds.components(separatedBy: ",").compactMap{ TopicId($0) })
        }, set: {
            topicIds = $0.map(\.description).joined(separator: ",")
        })
    }
}
