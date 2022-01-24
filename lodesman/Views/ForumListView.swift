//
//  ForumListView.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 23.01.2022.
//

import SwiftUI



struct ForumListView: View
{
    let forums: [Forum]
    @Binding var selection: Set<Int>

    var body: some View {
        List(forums, id: \.forumId, selection: $selection) { forum in
            ForumRow(forum: forum)
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
