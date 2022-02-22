//
//  ForumRow.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 23.01.2022.
//

import SwiftUI



struct ForumRow<Item: Forum & ObservableObject & Identifiable>: View
{
    @ObservedObject var forum: Item

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "dot.radiowaves.left.and.right")
                .foregroundColor(.accentColor)
                .updationState(forum.updationState)
            VStack(alignment: .leading) {
                Text(forum.title.rawValue)
                    .lineLimit(4)
                    .foregroundColor(.primary)
                    .font(.title2)
                if forum.lastUpdate != nil {
                    Text(dateFmt.string(from: forum.lastUpdate!))
                        .foregroundColor(.secondary)
                        .font(.callout)
                }
            }
            Spacer()
            Text("\(forum.numberOfTopics)")
                .foregroundColor(.secondary)
        }
    }
}

fileprivate let dateFmt: DateFormatter = {
    var result = DateFormatter()
    result.dateStyle = .short
    result.timeStyle = .short
    return result
}()


#if DEBUG
struct ForumRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForumRow(forum: ForumStub(lastUpdate: Date(), updationState: .failure))
            ForumRow(forum: ForumStub(lastUpdate: Date(), updationState: .loading))
            ForumRow(forum: ForumStub(lastUpdate: Date(), updationState: .waiting))
            ForumRow(forum: ForumStub(lastUpdate: Date(), updationState: .success))
        }
        .frame(width: 400)
    }
}
#endif
