//
//  ActivityLogView.swift
//  Purrl
//

import SwiftUI

struct ActivityLogView: View {
    @EnvironmentObject var monitor: ClipboardMonitor

    var body: some View {
        Group {
            if monitor.activityLog.isEmpty {
                Text("No activity yet")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(monitor.activityLog.reversed()) { entry in
                    ActivityLogRow(entry: entry)
                }
            }
        }
        .frame(width: 420, height: 360)
        .onAppear { NSApp.activate(ignoringOtherApps: true) }
    }
}

private struct ActivityLogRow: View {
    let entry: ClipboardMonitor.LogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(domain)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(1)
                Spacer()
                Text(entry.date, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(subtitle)
                .font(.caption)
                .foregroundColor(entry.skippedReason != nil ? .secondary : .green)
        }
        .padding(.vertical, 2)
    }

    private var domain: String {
        URL(string: entry.original)?.host?.hostWithoutWWW ?? "unknown"
    }

    private var subtitle: String {
        if let reason = entry.skippedReason {
            return "Skipped — \(reason)"
        }
        let n = entry.removedParams.count
        return "Cleaned \(n) param\(n == 1 ? "" : "s")"
    }
}
