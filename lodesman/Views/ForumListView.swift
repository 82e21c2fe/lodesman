//
//  ForumListView.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 23.01.2022.
//

import SwiftUI
import DomainPrimitives



struct ForumListView: View
{
    private let model: ViewModel
    @Binding private var selected: Set<ForumId>

    init(forums: [Forum], selection: Binding<Set<ForumId>>) {
        self.model = .init(forums: forums)
        self._selected = selection
    }

    var body: some View {
        List(selection: $selected) {
            ForEach(model.sections, id: \.caption) { section in
                Section(header: Text(section.caption.rawValue)) {
                    ForEach(section.forums, id: \.id) { forum in
                        ForumRow(forum: forum)
                    }
                }
            }
        }
        .frame(minWidth: 250)
    }
}


#if DEBUG
struct ForumListView_Previews: PreviewProvider {
    static var previews: some View {
        ForumListView(forums: ForumStub.preview, selection: .constant([]))
            .frame(width: 400)
    }
}
#endif
