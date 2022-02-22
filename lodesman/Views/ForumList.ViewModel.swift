//
//  ForumList.ViewModel.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 05.02.2022.
//

import Foundation
import DomainPrimitives


extension ForumListView
{
    struct ViewModel<Item: Forum & ObservableObject & Identifiable>
    {
        let sections: [(caption: ForumTitle, forums: [Item])]

        init(forums: [Item]) {
            sections = Dictionary(grouping: forums, by: { $0.section })
                .sorted(by: { lhs, rhs in lhs.key < rhs.key })
                .map({ (caption: $0.key, forums: $0.value) })
        }
    }
}
