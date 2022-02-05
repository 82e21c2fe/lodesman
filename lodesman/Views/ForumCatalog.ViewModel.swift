//
//  ForumCatalog.ViewModel.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 24.01.2022.
//

import SwiftUI
import Combine



extension ForumCatalogView
{
    final class ViewModel: ObservableObject
    {
        @Published private(set) var fetchedResult: Result<Catalog, FetchingError>?
        @Published var selection = Set<Int>()

        var catalog: Catalog? {
            guard case .success(let result) = fetchedResult else { return nil }
            return result
        }

        var selectedItems: [(section: String, forumId: Int, title: String)] {
            var temp = [Int:(section: String, title: String)]()
            for section in catalog?.root ?? [] {
                if selection.contains(section.id) {
                    section.forEachChildren { item in
                        assert(item.kind == .forum)
                        temp[item.id] = (section: section.title, title: item.title)
                    }
                }
                else {
                    section.forEachChildren { item in
                        if selection.contains(item.id) {
                            temp[item.id] = (section: section.title, title: item.title)
                            item.forEachChildren { subitem in
                                temp[subitem.id] = (section: section.title, title: subitem.title)
                            }
                        }
                    }
                }
            }
            return temp.map { element in
                (section: element.value.section, forumId: element.key, title: element.value.title)
            }
        }

        init(fetcher: ForumCatalogFetching) {
            self.fetcher = fetcher
        }

        func fetchCatalog() {
            cancellation?.cancel()
            cancellation = fetcher.fetchForumCatalog()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard case .failure(let error) = completion else { return }
                    self?.fetchedResult = .failure(error)
                } receiveValue: { [weak self] items in
                    self?.fetchedResult = .success(items)
                }
        }

        private var cancellation: AnyCancellable?
        private var fetcher: ForumCatalogFetching
    }
}
