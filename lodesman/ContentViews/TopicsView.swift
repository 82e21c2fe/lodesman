//
//  TopicsView.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 28.01.2022.
//

import SwiftUI
import DomainPrimitives


extension TopicGroupRule
{
    init(_ sortOrder: TopicSortOrder) {
        switch sortOrder {
        case .byLastUpdate: self = .byDay
        case .byTitle:      self = .byAlphabet
        }
    }
}


struct TopicsView<Storage: TopicStoring>: View
{
    @SceneStorage("topicTitleFilterText") private var filterText: String = ""
    @SceneStorage("topicSortOrder") private var sortOrder: TopicSortOrder = .byLastUpdate

    @ObservedObject var storage: Storage
    let forums: Set<ForumId>
    @Binding var selection: Set<TopicId>

    
    var body: some View {
        TopicListView(storage.topics(fromForums: forums, whereTitleContains: filterText, sortedBy: sortOrder),
                      groupRule: .init(sortOrder),
                      selection: $selection)
            .frame(minWidth: 250)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    TopicPinButton(storage: storage, selectedTopics: selection)
                    Spacer()
                    TopicSortOrderPicker(selection: $sortOrder)
                        .pickerStyle(.segmented)
                    Spacer()
                }
                ToolbarItem(placement: .principal) {
                    TextField("filter", text: $filterText)
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: 250, idealWidth: 450, maxWidth: 600)
                }
            }

    }
}


#if DEBUG
struct TopicsView_Previews: PreviewProvider {
    static var previews: some View {
        TopicsView(storage: TopicStorageStub(),
                   forums: [1],
                   selection: .constant([]))
    }
}
#endif
