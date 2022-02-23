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

    @State private var showForumCatalog = false
    @State private var selectedForums = Set<ForumId>()
    @State private var selectedTopics = Set<TopicId>()

    let forumStore: ForumStore
    let topicStore: TopicStore

    var body: some View {
        NavigationView {
            SidebarView(storage: forumStore,
                        selection: $selectedForums,
                        showForumCatalog: $showForumCatalog)
            TopicsView(storage: topicStore,
                       forums: selectedForums,
                       selection: $selectedTopics)
        }
        .sheet(isPresented: $showForumCatalog) {
            if let fetcher = ServerConnection(hostname: hostname) {
                ForumCatalogView(fetcher: fetcher) { items in
                    forumStore.insert(forums: items)
                }
            }
        }
    }
}
