//
//  SettingsView.swift
//  Purrl
//
//  Created by Daniel Jacob Chittoor on 02/03/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(SettingsKeys.autoCleanEnabled) private var autoCleanEnabled = true
    @AppStorage(SettingsKeys.showNotification) private var showNotification = false
    @AppStorage(SettingsKeys.launchAtLogin) private var launchAtLogin = false

    @AppStorage(SettingsKeys.customBlockedParams) private var customBlockedParams: [String] = []
    @AppStorage(SettingsKeys.whitelistedDomains) private var whitelistedDomains: [String] = []

    var body: some View {
        Form {
            Section("General") {
                Toggle("Auto-clean URLs from clipboard", isOn: $autoCleanEnabled)
                Toggle("Show notification when URL is cleaned", isOn: $showNotification)
                Toggle("Launch at login", isOn: $launchAtLogin)
            }


            Section("Custom Blocked Parameters") {
                Text("Additional URL parameters to strip (beyond built-in tracking params).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TagInputView(tags: $customBlockedParams, placeholder: "Add parameter name...")
            }

            Section("Whitelisted Domains") {
                Text("URLs from these domains will not be cleaned.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TagInputView(tags: $whitelistedDomains, placeholder: "Add domain (e.g. example.com)...")
            }

            Section {
                Button("Reset to Defaults") {
                    autoCleanEnabled = true
                    showNotification = false
                    launchAtLogin = false

                    customBlockedParams = []
                    whitelistedDomains = []
                }
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 450, minHeight: 400)
        .onAppear { NSApp.activate(ignoringOtherApps: true) }
    }
}

struct TagInputView: View {
    @Binding var tags: [String]
    var placeholder: String

    @State private var newTag = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FlowLayout(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    HStack(spacing: 4) {
                        Text(tag)
                            .font(.callout)
                        Button {
                            tags.removeAll { $0 == tag }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption2.weight(.bold))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
                }
            }

            HStack {
                TextField(placeholder, text: $newTag)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { addTag() }
                Button("Add") { addTag() }
                    .disabled(newTag.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func addTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespaces).lowercased()
        guard !trimmed.isEmpty, !tags.contains(trimmed) else {
            newTag = ""
            return
        }
        tags.append(trimmed)
        newTag = ""
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(in: proposal.width ?? 0, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(in: bounds.width, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(in width: CGFloat, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxWidth = max(maxWidth, x)
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
