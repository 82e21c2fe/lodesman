//
//  ServerConnecting.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 24.01.2022.
//

import Foundation
import Combine
import DomainPrimitives
import ServerConnector


protocol ServerConnecting
{
    func fetchForumCatalog() -> AnyPublisher<CatalogPage, ConnectingError>
    func fetchTopics(from forumId: ForumId, modifiedAfter earlyDate: Date) -> AnyPublisher<ForumPage, ConnectingError>
}

extension ServerConnection: ServerConnecting {}

extension ForumPage.Topic: TopicInfo {}

//MARK: - Adoption of `Catalog`

extension CatalogPage: Catalog
{
    var root: [CatalogItem] {
        sections
    }
}

extension CatalogPage.Section: CatalogItem
{
    var id: Int {
        -abs(title.hashValue)
    }

    var kind: CatalogItemKind {
        .section
    }

    var children: [CatalogItem]? {
        forums
    }
}

extension CatalogPage.Forum: CatalogItem
{
    var id: Int {
        forumId.rawValue
    }

    var kind: CatalogItemKind {
        .forum
    }

    var children: [CatalogItem]? {
        !subforums.isEmpty ? subforums : nil
    }
}
