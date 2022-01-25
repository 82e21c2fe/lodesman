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
        case .duplicate:    return .blue
        case .consumed:     return .gray
        }
    }
}


struct TopicRow: View
{
    private let viewModel: ViewModel

    init(_ topic: Topic) {
        viewModel = .init(topic)
    }

    var body: some View {
        HStack {
            VStack(alignment: .trailing, spacing: 5) {
                Text(viewModel.contentSize)
                    .foregroundColor(.secondary)
                    .font(.title3)
                Text(viewModel.status.rawValue)
                    .foregroundColor(viewModel.status.color)
                Text(viewModel.availability)
                    .foregroundColor(.yellow)
                Spacer()
            }
            .padding(.leading)
            .frame(width: 80)
            Divider()
            Text(viewModel.title)
                .lineLimit(4)
                .font(.title2)
                .foregroundColor(.primary)
            Spacer()
            Label("pinned", systemImage: "pin")
                .rotationEffect(.degrees(45))
                .labelStyle(.iconOnly)
                .imageScale(.large)
                .padding()
                .opacity(viewModel.pinned ? 1 : 0)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}



#if DEBUG
struct TopicRow_Previews: PreviewProvider {
    static let longTitle = repeatElement("a", count: 85).joined().capitalized
    static var previews: some View {
        Group {
            TopicRow(TopicStub(pinned: true, title: longTitle, status: .approved, availability: 5))
            TopicRow(TopicStub(status: .duplicate, contentSize: 0.5, availability: 3))
            TopicRow(TopicStub(status: .consumed, contentSize: 0.0004, availability: 0))
        }
        .frame(width: 400)
    }
}
#endif
