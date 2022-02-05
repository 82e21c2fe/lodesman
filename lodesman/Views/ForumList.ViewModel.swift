//
//  ForumList.ViewModel.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 05.02.2022.
//

import Foundation


extension ForumListView
{
    struct ViewModel
    {
        let sections: [(caption: String, forums: [Forum])]

        init(forums: [Forum]) {
            sections = Dictionary(grouping: forums, by: { $0.section.localizedCapitalized })
                .sorted(by: { lhs, rhs in lhs.key < rhs.key })
                .map({ (caption: $0.key, forums: $0.value) })
        }
    }
}
