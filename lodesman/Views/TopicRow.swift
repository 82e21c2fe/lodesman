//
//  TopicRow.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 25.01.2022.
//

import SwiftUI


extension TopicStatus
{
    var color: Color {
        switch self {
        case .approved:     return .green
        case .duplicate:    return .orange
        case .consumed:     return .gray
        }
    }
}


struct TopicRow: View
{
    private let topic: Topic

    init(_ topic: Topic) {
        self.topic = topic
    }

    var body: some View {
        HStack {
            VStack(alignment: .trailing) {
                Text(topic.status.rawValue)
                    .foregroundColor(topic.status.color)
                    .font(.title3)
                if topic.attachment != nil {
                    AttachmentView(topic.attachment!)
                }
            }
            .padding(.leading)
            .frame(width: 90)
            Divider()
            Text(topic.title)
                .lineLimit(4)
                .font(.title2)
                .foregroundColor(.primary)
            Spacer()
            Label("pinned", systemImage: "pin")
                .rotationEffect(.degrees(45))
                .labelStyle(.iconOnly)
                .imageScale(.large)
                .padding()
                .opacity(topic.pinned ? 1 : 0)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}


#if DEBUG
struct TopicRow_Previews: PreviewProvider {
    static let longTitle = repeatElement("a", count: 85).joined().capitalized

    static var previews: some View {
        Group {
            TopicRow(TopicStub(status: .approved,
                               title: longTitle,
                               attachment: AttachmentStub(availability: 5),
                               pinned: true))

            TopicRow(TopicStub(status: .duplicate,
                               attachment: AttachmentStub(size: 0.5, availability: 3)))

            TopicRow(TopicStub(status: .consumed))
        }
        .frame(width: 400)
    }
}
#endif
