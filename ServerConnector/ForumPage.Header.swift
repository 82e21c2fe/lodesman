//
//  ForumPage.Header.swift
//  ServerConnector
//
//  Created by Dmitri Shuvalov on 14.02.2022.
//

import Foundation
import DomainPrimitives


extension ForumPage
{
    public struct Header
    {
        public let href: URL
        public let title: ForumTitle
        public let currentPageIndex: PageIndex
        public let lastPageIndex: PageIndex
    }
}


extension ForumPage.Header
{
    init?(_ xmlString: String) {
        guard let document = try? XMLDocument(xmlString: xmlString, options: [.documentTidyXML,
                                                                        .nodeLoadExternalEntitiesNever])
            , let titleText = try? document.nodes(forXPath: XPathName.forumTitle).first?.textValue
            , let title = ForumTitle(rawValue: titleText)
            , let hrefText = try? document.nodes(forXPath: XPathName.forumHREF).first?.textValue
            , let href = URL(string: hrefText)
        else {
            return nil
        }

        let lastPage = (try? document.nodes(forXPath: XPathName.otherPage)
                            .compactMap({ PageIndex($0.textValue!) })
                            .sorted()
                            .last) ?? 1
        let currentPage = (try? document.nodes(forXPath: XPathName.currentPage)
                            .compactMap({ PageIndex($0.textValue!) })
                            .first) ?? lastPage

        self.init(href: href,
                  title: title,
                  currentPageIndex: currentPage,
                  lastPageIndex: max(currentPage, lastPage))
    }
}


fileprivate struct XPathName
{
    static let forumTitle = "//h1[@class='maintitle']/a[text()]"
    static let forumHREF = "//h1[@class='maintitle']/a/@href"
    static let currentPage = "//span[@class='pg-jump-menu']/../b"
    static let otherPage = "//span[@class='pg-jump-menu']/../a[@class='pg']"
}
