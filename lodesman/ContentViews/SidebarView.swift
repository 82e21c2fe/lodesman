//
//  SidebarView.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 28.01.2022.
//

import SwiftUI
import DomainPrimitives



struct SidebarView<Storage: ForumStorage>: View
{
    @ObservedObject var storage: Storage
    @Binding var selection: Set<ForumId>
    @Binding var showForumCatalog: Bool
    @State private var listId = 0

    var body: some View {
        VStack {
            Divider()
            ForumListView(forums: storage.forums, selection: $selection)
                .id(listId) // BUG: glich screen
            HStack {
                ForumSubscriptionButton(showForumCatalog: $showForumCatalog)
                ForumUnsubscriptionButton(storage: storage, selection: $selection)
                Spacer()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .padding()
        }
        .onReceive(storage.objectWillChange, perform: { _ in
            listId += 1
        })
        .frame(minWidth: 250)
        .toolbar {
            ToggleSidebarButton()
        }
    }
}


#if DEBUG
struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView(storage: ForumStorageStub(), selection: .constant([]), showForumCatalog: .constant(false))
            .frame(width: 400)
    }
}
#endif
