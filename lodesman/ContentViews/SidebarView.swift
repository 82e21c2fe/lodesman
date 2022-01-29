//
//  SidebarView.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 28.01.2022.
//

import SwiftUI



struct SidebarView<Storage: ForumStorage>: View
{
    @ObservedObject var storage: Storage
    @Binding var selection: Set<Int>
    @Binding var showForumCatalog: Bool

    var body: some View {
        VStack {
            Divider()
            ForumListView(forums: storage.forums, selection: $selection)
            HStack {
                ForumSubscriptionButton(showForumCatalog: $showForumCatalog)
                ForumUnsubscriptionButton(storage: storage, selection: $selection)
                Spacer()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .padding()
        }
        .frame(minWidth: 250)
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