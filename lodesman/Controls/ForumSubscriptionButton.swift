//
//  ForumSubscriptionButton.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 28.01.2022.
//

import SwiftUI



struct ForumSubscriptionButton: View
{
    @Binding var showForumCatalog: Bool

    var body: some View {
        Button {
            showForumCatalog.toggle()
        } label: {
            Label("Subscribe to forums...", systemImage: "plus.circle")
        }
        .keyboardShortcut("n", modifiers: [.command])
    }
}


#if DEBUG
struct ForumSubscriptionButton_Previews: PreviewProvider {
    static var previews: some View {
        ForumSubscriptionButton(showForumCatalog: .constant(false))
    }
}
#endif
