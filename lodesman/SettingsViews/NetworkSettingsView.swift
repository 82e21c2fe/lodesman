//
//  NetworkSettingsView.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 16.02.2022.
//

import SwiftUI


struct NetworkSettingsView: View
{
    @AppStorage(SettingsKey.hostname) private var hostname = ""
    @AppStorage(SettingsKey.updateInterval) private var interval = 24.0

    var body: some View {
        Form {
            TextField("Hostname", text: $hostname)
            Slider(value: $interval, in: 4...168, step: 4) {
                VStack(alignment: .trailing) {
                Text("Update interval")
                Text("(\(Int(interval)) hours)")
                }
            }
        }
        .padding(20)
        .frame(width: 350, height: 100)
    }
}


#if DEBUG
struct NetworkSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkSettingsView()
    }
}
#endif
