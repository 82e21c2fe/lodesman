//
//  TopicSortOrderPicker.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 28.01.2022.
//

import SwiftUI



extension TopicSortOrder
{
    var content: (title: String, systemImage: String) {
        switch self {
        case .byLastUpdate: return (title: "by last update", systemImage: "calendar")
        case .byTitle:      return (title: "by title", systemImage: "list.dash")
        }
    }
}


struct TopicSortOrderPicker: View
{
    @Binding var selection: TopicSortOrder

    var body: some View {
        Picker("Sort order or topics", selection: $selection) {
            ForEach(TopicSortOrder.allCases) { order in
                Label(order.content.title, systemImage: order.content.systemImage)
            }
        }
    }
}


#if DEBUG
struct TopicSortOrderPicker_Previews: PreviewProvider {
    static var previews: some View {
        TopicSortOrderPicker(selection: .constant(.byTitle))
            .labelStyle(.iconOnly)
            .labelsHidden()
            .pickerStyle(.segmented)
            .fixedSize()
    }
}
#endif
