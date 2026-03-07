//
//  ClipboardMonitorTests.swift
//  PurrlTests
//

import Foundation
import Testing
@testable import Purrl

struct WhitelistTests {

    private func monitor() -> ClipboardMonitor { ClipboardMonitor() }

    // MARK: - Exact domain matching

    @Test func exactDomainIsWhitelisted() {
        let m = monitor()
        #expect(m.isWhitelisted(host: "example.com", domains: ["example.com"]))
    }

    @Test func wwwPrefixMatchesBareDomain() {
        let m = monitor()
        #expect(m.isWhitelisted(host: "www.example.com", domains: ["example.com"]))
    }

    @Test func bareDomainMatchesWhenWWWInList() {
        let m = monitor()
        #expect(m.isWhitelisted(host: "example.com", domains: ["www.example.com"]))
    }

    @Test func nonMatchingDomainIsNotWhitelisted() {
        let m = monitor()
        #expect(!m.isWhitelisted(host: "other.com", domains: ["example.com"]))
    }

    @Test func caseInsensitiveMatching() {
        let m = monitor()
        #expect(m.isWhitelisted(host: "Example.COM", domains: ["example.com"]))
    }

    // MARK: - Wildcard subdomain matching

    @Test func wildcardMatchesSubdomain() {
        let m = monitor()
        #expect(m.isWhitelisted(host: "blog.example.com", domains: ["*.example.com"]))
    }

    @Test func wildcardMatchesDeepSubdomain() {
        let m = monitor()
        #expect(m.isWhitelisted(host: "a.b.example.com", domains: ["*.example.com"]))
    }

    @Test func wildcardMatchesBareDomain() {
        let m = monitor()
        #expect(m.isWhitelisted(host: "example.com", domains: ["*.example.com"]))
    }

    @Test func wildcardDoesNotMatchDifferentDomain() {
        let m = monitor()
        #expect(!m.isWhitelisted(host: "notexample.com", domains: ["*.example.com"]))
    }

    @Test func wildcardDoesNotMatchPartialSuffix() {
        let m = monitor()
        #expect(!m.isWhitelisted(host: "badexample.com", domains: ["*.example.com"]))
    }
}

struct URLValidationTests {

    private func monitor() -> ClipboardMonitor { ClipboardMonitor() }

    // MARK: - Authentication URLs

    @Test func rejectsURLWithUserInfo() {
        let m = monitor()
        #expect(m.validatedURL(from: "https://user:pass@host.com/path") == nil)
    }

    @Test func rejectsURLWithUserOnly() {
        let m = monitor()
        #expect(m.validatedURL(from: "https://user@host.com/path") == nil)
    }

    // MARK: - Fragment-only URLs (no query params)

    @Test func fragmentOnlyURLPassesValidation() {
        let m = monitor()
        let url = m.validatedURL(from: "https://example.com#section")
        #expect(url != nil)
        // Sanitizer will return .unchanged, so it won't be modified
    }

    // MARK: - Length limits

    @Test func rejectsURLOver2048Chars() {
        let m = monitor()
        let long = "https://example.com/" + String(repeating: "a", count: 2030)
        #expect(long.count > 2048)
        #expect(m.validatedURL(from: long) == nil)
    }

    @Test func acceptsURLAtExactly2048Chars() {
        let m = monitor()
        let base = "https://example.com/"
        let url = base + String(repeating: "a", count: 2048 - base.count)
        #expect(url.count == 2048)
        #expect(m.validatedURL(from: url) != nil)
    }

    // MARK: - Multiple URLs / text blocks

    @Test func rejectsMultipleURLsSeparatedBySpace() {
        let m = monitor()
        #expect(m.validatedURL(from: "https://a.com https://b.com") == nil)
    }

    @Test func rejectsTextWithTab() {
        let m = monitor()
        #expect(m.validatedURL(from: "https://a.com\thttps://b.com") == nil)
    }

    @Test func rejectsMultilineText() {
        let m = monitor()
        #expect(m.validatedURL(from: "https://a.com\nhttps://b.com") == nil)
    }

    // MARK: - Non-HTTP schemes

    @Test func rejectsCallbackScheme() {
        let m = monitor()
        #expect(m.validatedURL(from: "x-callback://action") == nil)
    }

    @Test func rejectsObsidianScheme() {
        let m = monitor()
        #expect(m.validatedURL(from: "obsidian://open?vault=test") == nil)
    }

    @Test func rejectsFileScheme() {
        let m = monitor()
        #expect(m.validatedURL(from: "file:///Users/test/doc.txt") == nil)
    }

    // MARK: - Whitespace trimming

    @Test func trimsLeadingTrailingWhitespace() {
        let m = monitor()
        let url = m.validatedURL(from: "  https://example.com/path  ")
        #expect(url != nil)
        #expect(url?.absoluteString == "https://example.com/path")
    }
}

struct CustomParamsTests {

    @Test func customParamStrippedAlongsideDefaults() {
        let result = URLSanitizer.sanitize(
            "https://example.com?utm_source=twitter&session_id=abc&q=hello",
            additionalParams: ["session_id"]
        )
        guard case .cleaned(_, let cleaned, let removed) = result else {
            Issue.record("Expected .cleaned result")
            return
        }
        #expect(cleaned == "https://example.com?q=hello")
        #expect(Set(removed) == Set(["utm_source", "session_id"]))
    }

    @Test func onlyCustomParamStripped() {
        let result = URLSanitizer.sanitize(
            "https://example.com?custom_track=1&q=hello",
            additionalParams: ["custom_track"]
        )
        guard case .cleaned(_, let cleaned, let removed) = result else {
            Issue.record("Expected .cleaned result")
            return
        }
        #expect(cleaned == "https://example.com?q=hello")
        #expect(removed == ["custom_track"])
    }

    @Test func customParamCaseInsensitive() {
        let result = URLSanitizer.sanitize(
            "https://example.com?MyParam=val&q=1",
            additionalParams: ["myparam"]
        )
        guard case .cleaned(_, let cleaned, _) = result else {
            Issue.record("Expected .cleaned result")
            return
        }
        #expect(cleaned == "https://example.com?q=1")
    }

    @Test func noCustomParamsNoEffect() {
        let result = URLSanitizer.sanitize(
            "https://example.com?q=hello",
            additionalParams: ["session_id"]
        )
        #expect(result == .unchanged("https://example.com?q=hello"))
    }
}

struct ActivityLogTests {

    private func monitor() -> ClipboardMonitor { ClipboardMonitor() }

    private func makeEntry(original: String = "https://example.com", cleaned: String? = nil, skippedReason: String? = nil) -> ClipboardMonitor.LogEntry {
        ClipboardMonitor.LogEntry(date: .now, original: original, cleaned: cleaned, removedParams: [], skippedReason: skippedReason)
    }

    @Test func logStoresEntries() {
        let m = monitor()
        m.appendLog(makeEntry(original: "https://a.com"))
        m.appendLog(makeEntry(original: "https://b.com"))
        #expect(m.activityLog.count == 2)
    }

    @Test func logAppendsNewestLast() {
        let m = monitor()
        m.appendLog(makeEntry(original: "https://first.com"))
        m.appendLog(makeEntry(original: "https://second.com"))
        #expect(m.activityLog[0].original == "https://first.com")
        #expect(m.activityLog[1].original == "https://second.com")
    }

    @Test func logRotatesAt20() {
        let m = monitor()
        for i in 0..<25 {
            m.appendLog(makeEntry(original: "https://\(i).com"))
        }
        #expect(m.activityLog.count == 20)
    }

    @Test func logKeepsNewestAfterRotation() {
        let m = monitor()
        for i in 0..<25 {
            m.appendLog(makeEntry(original: "https://\(i).com"))
        }
        // Oldest kept entry (i=5) should be first
        #expect(m.activityLog[0].original == "https://5.com")
        // Newest entry (i=24) should be last
        #expect(m.activityLog[19].original == "https://24.com")
    }

    @Test func logDistinguishesCleanedAndSkipped() {
        let m = monitor()
        m.appendLog(makeEntry(cleaned: "https://clean.com", skippedReason: nil))
        m.appendLog(makeEntry(skippedReason: "whitelisted"))
        #expect(m.activityLog[0].skippedReason == nil)
        #expect(m.activityLog[1].skippedReason == "whitelisted")
    }
}
