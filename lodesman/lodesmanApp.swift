//
//  lodesmanApp.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 23.01.2022.
//

import SwiftUI


struct SettingsKey {
    static let hostname = "hostname"
    static let updateInterval = "updateInterval"
}



@main
struct lodesmanApp: App
{
    let persistent = Persistent.shared
    let updationManager: UpdationManager

    init() {
        UserDefaults.standard.register(defaults: [
            SettingsKey.hostname: "",
            SettingsKey.updateInterval: 24.0
        ])
        updationManager = UpdationManager(persistent: persistent)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(forumStore: persistent.forumStore, topicStore: persistent.topicStore)
        }
        Settings {
            SettingsView()
        }
    }
}
