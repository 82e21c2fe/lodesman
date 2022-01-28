//
//  ForumUnsubscriptionButton.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 28.01.2022.
//

import SwiftUI



struct ForumUnsubscriptionButton: View
{
    let storage: ForumStorage
    @Binding var selection: Set<Int>

    var body: some View {
        Button {
            storage.remove(forums: selection)
            selection = []
        } label: {
            Label("Unsubscribe from selected forums", systemImage: "minus.circle")
        }
        .disabled(selection.isEmpty)
    }
}


#if DEBUG
struct ForumUnsubscriptionButton_Previews: PreviewProvider {
    static var previews: some View {
        ForumUnsubscriptionButton(storage: ForumStorageStub(), selection: .constant([]))
    }
}
#endif
