//
//  ForumUnsubscriptionButton.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 28.01.2022.
//

import SwiftUI
import DomainPrimitives



struct ForumUnsubscriptionButton<Storage: ForumStorage>: View
{
    let storage: Storage
    @Binding var selection: Set<ForumId>

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
