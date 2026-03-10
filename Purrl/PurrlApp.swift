//
//  PurrlApp.swift
//  Purrl
//
//  Created by Daniel Jacob Chittoor on 02/03/26.
//

import SwiftUI

@main
struct PurrlApp: App {
    @StateObject private var clipboardMonitor = ClipboardMonitor()

    init() {
        SettingsKeys.registerDefaults()
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(monitor: clipboardMonitor)
        } label: {
            Image(systemName: clipboardMonitor.menuBarIcon)
        }
        .menuBarExtraStyle(.menu)

        Window("Recent Activity", id: "activity-log") {
            ActivityLogView()
                .environmentObject(clipboardMonitor)
        }
        .defaultSize(width: 420, height: 360)

        Settings {
            SettingsView()
        }
    }
}
