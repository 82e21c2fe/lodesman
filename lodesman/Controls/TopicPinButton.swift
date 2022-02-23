//
//  TopicPinButton.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 28.01.2022.
//

import SwiftUI
import DomainPrimitives



struct TopicPinButton<Storage: TopicStoring>: View
{
    let storage: Storage
    let selectedTopics: Set<TopicId>

    var body: some View {
        Button {
            storage.togglePin(forTopics: selectedTopics)
        } label: {
            Label("Pin or unpin topics", systemImage: "pin")
        }
        .keyboardShortcut(".", modifiers: [.command])
        .disabled(selectedTopics.isEmpty)
    }
}


#if DEBUG
struct TopicPinButton_Previews: PreviewProvider {
    static var previews: some View {
        TopicPinButton(storage: TopicStorageStub(), selectedTopics: [])
    }
}
#endif
