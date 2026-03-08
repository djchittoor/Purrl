//
//  SettingsKeys.swift
//  Purrl
//
//  Created by Daniel Jacob Chittoor on 02/03/26.
//

import Foundation

enum SettingsKeys {
    static let autoCleanEnabled = "autoCleanEnabled"

    static let customBlockedParams = "customBlockedParams"
    static let whitelistedDomains = "whitelistedDomains"
    static let cleaningMode = "cleaningMode"

    static let embedFixTwitter = "embedFixTwitter"
    static let embedFixInstagram = "embedFixInstagram"
    static let embedFixReddit = "embedFixReddit"
    static let embedFixBluesky = "embedFixBluesky"

    // MARK: - Default values (single source of truth)

    static let defaultAutoCleanEnabled = true
    static let defaultCleaningMode = "standard"
    static let defaultEmbedFixTwitter = false
    static let defaultEmbedFixInstagram = false
    static let defaultEmbedFixReddit = false
    static let defaultEmbedFixBluesky = false

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            autoCleanEnabled: defaultAutoCleanEnabled,

            customBlockedParams: "[]",
            whitelistedDomains: "[]",
            cleaningMode: defaultCleaningMode,

            embedFixTwitter: defaultEmbedFixTwitter,
            embedFixInstagram: defaultEmbedFixInstagram,
            embedFixReddit: defaultEmbedFixReddit,
            embedFixBluesky: defaultEmbedFixBluesky,
        ])
    }
}

// Allow @AppStorage to work with [String] by storing as JSON
extension Array: @retroactive RawRepresentable where Element == String {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let array = try? JSONDecoder().decode([String].self, from: data) else {
            return nil
        }
        self = array
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return string
    }
}
