//
//  SettingsView.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 16.02.2022.
//

import SwiftUI


struct SettingsView: View {
    var body: some View {
        TabView {
            NetworkSettingsView()
                .tabItem { Label("Network", systemImage: "network") }
        }
        .padding(20)
        .frame(width: 375, height: 150)
    }
}


#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
