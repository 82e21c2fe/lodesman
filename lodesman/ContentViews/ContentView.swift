//
//  ContentView.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 23.01.2022.
//

import SwiftUI
import DomainPrimitives



struct ContentView: View
{
    @ObservedObject var model: ViewModel

    var body: some View {
        NavigationView {
            SidebarView(storage: model.storage,
                        selection: $model.selectedForums,
                        showForumCatalog: $model.showForumCatalog)
            TopicsView(storage: model.storage,
                       forums: model.selectedForums,
                       selection: $model.selectedTopics)
        }
        .sheet(isPresented: $model.showForumCatalog) {
            ForumCatalogView(fetcher: model.fetcher) { items in
                model.subscribe(to: items)
            }
        }
    }
}
