//
//  TopicListView.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 25.01.2022.
//

import SwiftUI
import DomainPrimitives


enum TopicGroupRule {
    case byDay, byAlphabet
}


struct TopicListView<Item: Topic & ObservableObject & Identifiable>: View
{
    private let viewModel: ViewModel<Item>
    @Binding private var selected: Set<TopicId>

    init(_ topics: [Item], groupRule: TopicGroupRule, selection: Binding<Set<TopicId>>) {
        self.viewModel = .init(topics, groupRule: groupRule)
        self._selected = selection
    }

    var body: some View {
        List(selection: $selected) {
            ForEach(viewModel.section, id: \.caption) { section in
                Section(header: Text(section.caption)) {
                    ForEach(section.topics) { topic in
                        TopicRow(topic: topic)
                            .background(Color.gray.opacity(0.05))
                    }
                }
            }
        }
    }
}


#if DEBUG
struct TopicListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TopicListView(TopicStub.preview, groupRule: .byDay, selection: .constant([]))
            TopicListView(TopicStub.preview, groupRule: .byAlphabet, selection: .constant([]))
        }
        .frame(width: 400)
    }
}
#endif
