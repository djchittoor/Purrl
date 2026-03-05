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

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            autoCleanEnabled: true,

            customBlockedParams: "[]",
            whitelistedDomains: "[]",
            cleaningMode: "standard",

            embedFixTwitter: false,
            embedFixInstagram: false,
            embedFixReddit: false,
            embedFixBluesky: false,
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
