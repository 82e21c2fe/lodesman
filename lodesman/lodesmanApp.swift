//
//  lodesmanApp.swift
//  lodesman
//
//  Created by Dmitri Shuvalov on 23.01.2022.
//

import SwiftUI
import ServerConnector


@main
struct lodesmanApp: App
{
    let persistent = Persistent.shared
    let fetcher = ServerConnection(hostname: "localhost")!

    var body: some Scene {
        WindowGroup {
            ContentView(model: .init(storage: Storage(context: persistent.container.viewContext),
                                     fetcher: fetcher))
        }
    }
}
