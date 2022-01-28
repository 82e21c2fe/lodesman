//
//  ToggleSidebarButton.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 28.01.2022.
//

import SwiftUI



struct ToggleSidebarButton: View
{
    var body: some View {
        Button {
            NSApp.sendAction(#selector(NSSplitViewController.toggleSidebar(_:)), to: nil, from: nil)
        } label: {
            Label("Hide or show the forums", systemImage: "sidebar.left")
        }
    }
}


#if DEBUG
struct ToggleSidebarButton_Previews: PreviewProvider {
    static var previews: some View {
        ToggleSidebarButton()
    }
}
#endif
