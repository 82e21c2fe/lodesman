//
//  CatalogPage.swift
//  ServerConnector
//
//  Created by Dmitri Shuvalov on 29.01.2022.
//

import Foundation
import DomainPrimitives



public struct CatalogPage
{
    public var sections: [CatalogPage.Section]

    public struct Section
    {
        public var title: ForumTitle
        public var forums: [CatalogPage.Forum]
    }

    public struct Forum
    {
        public var forumId: ForumId
        public var title: ForumTitle
        public var subforums: [CatalogPage.Forum]
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
            throw ConnectingError.parsing
        }
    }
}

extension CatalogPage.Section
{
    init?(_ node: XMLNode) {
        precondition(node.kind == .element)
        precondition(node.name == "li")

        guard let text = try? node.nodes(forXPath: XPathName.sectionTitle).first?.textValue
            , let title = ForumTitle(rawValue: text)
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
            , let forumId = ForumId(href)
        else {
            return nil
        }

        guard let text = try? node.nodes(forXPath: XPathName.forumTitle).first?.textValue
            , let title = ForumTitle(rawValue: text)
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
