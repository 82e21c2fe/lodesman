//
//  Catalog.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 24.01.2022.
//

import Foundation



enum CatalogItemKind {
    case section, forum
}


protocol CatalogItem
{
    var id: Int { get }
    var kind: CatalogItemKind { get }
    var title: String { get }
    var children: [CatalogItem]? { get }
}


protocol Catalog
{
    var root: [CatalogItem] { get }
}


//MARK: - forEach
extension CatalogItem
{
    func forEachChildren(_ body: (CatalogItem) -> Void) {
        for child in children ?? [] {
            body(child)
            child.forEachChildren(body)
        }
    }
}

extension Catalog
{
    func forEach(_ body: (CatalogItem) -> Void) {
        for item in root {
            body(item)
            item.forEachChildren(body)
        }
    }
}


//MARK: -

#if DEBUG
struct CatalogItemStub: CatalogItem
{
    var id: Int
    var kind: CatalogItemKind { id < 0 ? .section : .forum }
    var title: String
    var children: [CatalogItem]?
}

struct CatalogStub: Catalog
{
    var root: [CatalogItem]

    static let preview = CatalogStub(root: [
        CatalogItemStub(id: -11, title: "primary section", children: [
            CatalogItemStub(id: 12, title: "alpha"),
            CatalogItemStub(id: 13, title: "beta", children: [
                CatalogItemStub(id: 14, title: "gamma from beta")]),
            CatalogItemStub(id: 15, title: "zeta")]),
        CatalogItemStub(id: -13, title: "secondary section", children: [
            CatalogItemStub(id: 21, title: "alpha from secondary"),
            CatalogItemStub(id: 22, title: "beta from secondary")])
    ])
}
#endif
