//
//  MenuBarView.swift
//  Purrl
//
//  Created by Daniel Jacob Chittoor on 02/03/26.
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var monitor: ClipboardMonitor
    @AppStorage(SettingsKeys.autoCleanEnabled) private var autoCleanEnabled = SettingsKeys.defaultAutoCleanEnabled
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Toggle("Auto-clean: \(autoCleanEnabled ? "ON" : "OFF")", isOn: $autoCleanEnabled)

        Button(pauseButtonLabel) {
            if monitor.isPaused {
                monitor.resumeFromPause()
            } else {
                monitor.pauseForOneHour()
            }
        }

        Divider()

        Text(lastCleanedLabel)

        Button("Recent Activity...") {
            openWindow(id: "activity-log")
        }

        Divider()

        SettingsLink {
            Text("Settings...")
        }
        .keyboardShortcut(",", modifiers: .command)

        Button("Quit Purrl") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }

    private var pauseButtonLabel: String {
        monitor.isPaused ? "Resume" : "Pause for 1 hour"
    }

    private var lastCleanedLabel: String {
        guard let entry = monitor.lastCleanedResult else {
            return "Last cleaned: none"
        }
        let domain = URL(string: entry.cleaned).flatMap(\.host) ?? "URL"
        let n = entry.removedParams.count
        return "Cleaned \(domain) (\(n) param\(n == 1 ? "" : "s"))"
    }
}
