//
//  lodesmanApp.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 23.01.2022.
//

import SwiftUI
import ServerConnector


struct SettingsKey {
    static let hostname = "hostname"
    static let updateInterval = "updateInterval"
}



@main
struct lodesmanApp: App
{
    let persistent = Persistent.shared
    let fetcher = ServerConnection(hostname: "localhost")!

    init() {
        UserDefaults.standard.register(defaults: [
            SettingsKey.hostname: "",
            SettingsKey.updateInterval: 24.0
        ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView(model: .init(storage: Storage(context: persistent.container.viewContext),
                                     fetcher: fetcher))
        }
        Settings {
            SettingsView()
        }
    }
}
