//
//  ForumRow.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 23.01.2022.
//

import SwiftUI



struct ForumRow: View
{
    let forum: Forum

    var body: some View {
        HStack {
            Image(systemName: "dot.radiowaves.left.and.right")
                .foregroundColor(.accentColor)
            Text(forum.title)
                .foregroundColor(.primary)
            Spacer()
            Text("\(forum.numberOfTopics)")
                .foregroundColor(.secondary)
        }
    }
}



struct ForumRow_Previews: PreviewProvider {
    static var previews: some View {
        ForumRow(forum: ForumStub())
            .frame(width: 400)
    }
}
