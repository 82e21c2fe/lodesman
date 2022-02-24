//
//  TopicList.ViewModel.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 25.01.2022.
//

import SwiftUI


extension TopicListView
{
    struct ViewModel<Item: Topic & ObservableObject & Identifiable>
    {
        let section: [(caption: String, topics: [Item])]

        init(_ topics: [Item], groupRule: TopicGroupRule) {
            var items = topics
            let index = items.partition(by: { !$0.pinned })
            let pinned = items[..<index]
            let other = items[index...]

            var temp = !pinned.isEmpty ? [(caption: "Pinned", topics: Array(pinned))] : []

            switch groupRule {
            case .byDay:
                temp += Dictionary(grouping: other, by: { Calendar.current.startOfDay(for: $0.lastUpdate) })
                    .sorted(by: { lhs, rhs in lhs.key > rhs.key })
                    .map { (caption: dateFmt.string(from: $0.key), topics: $0.value) }

            case .byAlphabet:
                temp += Dictionary(grouping: other, by: { $0.title.firstLetter })
                    .sorted(by: { lhs, rhs in lhs.key < rhs.key })
                    .map { (caption: $0.key, topics: $0.value) }
            }
            section = temp
        }
    }
}


fileprivate let dateFmt: DateFormatter = {
    var result = DateFormatter()
    result.dateStyle = .long
    result.timeStyle = .none
    result.doesRelativeDateFormatting = true
    return result
}()
