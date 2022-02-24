//
//  TopicRow.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 25.01.2022.
//

import SwiftUI
import DomainPrimitives


extension TopicStatus
{
    var color: Color {
        switch self {
        case .unknown:      return .orange
        case .approved:     return .green
        case .duplicate:    return .orange
        case .consumed:     return .gray
        }
    }
}


struct TopicRow<Item: Topic & ObservableObject & Identifiable>: View
{
    @ObservedObject var topic: Item

    var body: some View {
        HStack {
            VStack(alignment: .trailing) {
                Text(topic.status.rawValue)
                    .foregroundColor(topic.status.color)
                    .font(.title3)
                ContentSizeView(topic.contentSize)
                AvailabilityView(topic.availability)
            }
            .padding(.leading)
            .frame(width: 90)
            Divider()
            Text(topic.title.rawValue)
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
            TopicRow(topic: TopicStub(status: .approved,
                                      title: TopicTitle(rawValue: longTitle)!,
                                      availability: 5,
                                      pinned: true))

            TopicRow(topic: TopicStub(status: .unknown, contentSize: 0.00043, availability: 1))
            TopicRow(topic: TopicStub(status: .duplicate, contentSize: 0.5, availability: 3))
            TopicRow(topic: TopicStub(status: .consumed))
        }
        .frame(width: 400)
    }
}
#endif
