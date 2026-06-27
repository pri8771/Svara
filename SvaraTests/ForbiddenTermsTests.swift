import XCTest
@testable import Svara

/// Guards the anti-Primandir constraints: forbidden, temple-coded feature terms
/// must never appear in user-facing content labels. See ProductGuardrails §3.
final class ForbiddenTermsTests: XCTestCase {

    private var provider: SeedContentProvider!

    override func setUp() {
        super.setUp()
        provider = SeedContentProvider(bundle: .main)
    }

    func testForbiddenTermDetectionMatchesCaseInsensitively() {
        XCTAssertEqual(ContentValidation.forbiddenTerms(in: "Book a Virtual Puja now"), ["virtual puja"])
        XCTAssertEqual(ContentValidation.forbiddenTerms(in: "DARSHAN BOOKING"), ["darshan booking"])
        XCTAssertTrue(ContentValidation.forbiddenTerms(in: "A calm morning mantra").isEmpty)
    }

    func testDetectsMultipleForbiddenTerms() {
        let found = ContentValidation.forbiddenTerms(in: "live temple with priest booking")
        XCTAssertTrue(found.contains("live temple"))
        XCTAssertTrue(found.contains("priest booking"))
    }

    func testSeedContentContainsNoForbiddenTerms() {
        let issues = ContentValidation.scanForbiddenTerms(
            mantras: provider.mantras,
            lessons: provider.lessons,
            festivals: provider.festivals,
            stories: provider.stories,
            shlokas: provider.shlokas,
            achievements: provider.achievements
        )
        XCTAssertTrue(issues.isEmpty, "Forbidden terms found in seed labels:\n" + issues.map(\.description).joined(separator: "\n"))
    }

    func testScannerFlagsInjectedForbiddenLabel() {
        let badStory = StorySymbol(
            id: "bad", title: "Temple Marketplace", deity: "X", theme: .wisdom,
            summary: "s", story: "body", symbolMeaning: "m", takeaway: "t"
        )
        let issues = ContentValidation.scanForbiddenTerms(
            mantras: [], lessons: [], festivals: [], stories: [badStory],
            shlokas: [], achievements: []
        )
        XCTAssertTrue(issues.contains { $0.message.contains("temple marketplace") })
    }

    /// No bell symbol leaks into the canonical symbol system (product review).
    func testSymbolSystemExcludesBell() {
        for symbol in SvaraSymbol.allCases {
            XCTAssertFalse(symbol.systemImage.lowercased().contains("bell"),
                           "\(symbol.label) uses a bell glyph")
            XCTAssertNotEqual(symbol.rawValue, "bell")
        }
    }
}
