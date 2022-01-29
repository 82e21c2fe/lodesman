//
//  CatalogPage.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 29.01.2022.
//

import Foundation



struct CatalogPage
{
    var sections: [CatalogPage.Section]

    struct Section
    {
        var title: String
        var forums: [CatalogPage.Forum]
    }

    struct Forum
    {
        var forumId: Int
        var title: String
        var subforums: [CatalogPage.Forum]
    }
}

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
        forumId
    }

    var kind: CatalogItemKind {
        .forum
    }

    var children: [CatalogItem]? {
        !subforums.isEmpty ? subforums : nil
    }
}


//MARK: - HTML Parser

extension CatalogPage
{
    init(data: Data) throws {
        do {
            let html = String(data: data, encoding: .windowsCP1251)!
            let document = try XMLDocument(xmlString: html, options: [.documentTidyXML,
                                                                      .nodeLoadExternalEntitiesNever])
            let roots = try document.nodes(forXPath: XPathName.treeRoot)
            sections = roots.compactMap { CatalogPage.Section($0) }
        }
        catch {
            throw FetchingError.parsing
        }
    }
}

extension CatalogPage.Section
{
    init?(_ node: XMLNode) {
        precondition(node.kind == .element)
        precondition(node.name == "li")

        guard let title = try? node.nodes(forXPath: XPathName.sectionTitle).first?.textValue
            , (1...256).contains(title.count)
        else {
            return nil
        }

        guard let children = (try? node.nodes(forXPath: XPathName.children))?.compactMap({ CatalogPage.Forum($0) })
            , !children.isEmpty
        else {
            return nil
        }

        self.init(title: title, forums: children)
    }
}


extension CatalogPage.Forum
{
    init?(_ node: XMLNode) {
        precondition(node.kind == .element)
        precondition(node.name == "li")

        guard let href = try? node.nodes(forXPath: XPathName.forumId).first?.textValue
            , let forumId = Int(href)
            , 0 < forumId
        else {
            return nil
        }

        guard let title = try? node.nodes(forXPath: XPathName.forumTitle).first?.textValue
            , (1...256).contains(title.count)
        else {
            return nil
        }

        guard let children = (try? node.nodes(forXPath: XPathName.children))?.compactMap({ CatalogPage.Forum($0) })
        else {
            return nil
        }

        self.init(forumId: forumId, title: title, subforums: children)
    }
}


//MARK: -

fileprivate struct XPathName
{
    static let treeRoot = "//ul[@class='tree-root']/li"
    static let forumId = "./span/a[@href]/@href"
    static let forumTitle = "./span/a[@href]"
    static let sectionTitle = "./span/span[@class='c-title']/@title"
    static let children = "./ul/li"
}
