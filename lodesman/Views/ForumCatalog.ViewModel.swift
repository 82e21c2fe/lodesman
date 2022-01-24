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

        var selectedItems: [CatalogItem] {
            var result = [CatalogItem]()
            catalog?.forEach { item in
                if selection.contains(item.id) {
                    result.append(item)
                }
            }
            return result
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
