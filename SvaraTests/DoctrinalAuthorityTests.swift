import XCTest
@testable import Svara

/// Strategy lock: "no authoritative ruling/doctrine content." This makes the
/// guardrail executable (mirroring the anti-Primandir forbidden-term checks):
/// shipped content must use humble, plural framing, never absolutist claims.
final class DoctrinalAuthorityTests: XCTestCase {

    private var provider: SeedContentProvider!

    override func setUp() {
        super.setUp()
        provider = SeedContentProvider(bundle: .main)
    }

    func testShippedContentHasNoDoctrinalAuthorityPhrasing() throws {
        let mantras = try provider.decode([Mantra].self, from: "seed_mantras")
        let lessons = try provider.decode([Lesson].self, from: "seed_lessons")
        let festivals = try provider.decode([Festival].self, from: "seed_festivals")
        let stories = try provider.decode([StorySymbol].self, from: "seed_stories")
        let shlokas = try provider.decode([ShlokaOfDay].self, from: "seed_shlokas")
        let library = try provider.decode([Story].self, from: "seed_story_library")

        var issues = ContentValidation.scanDoctrinalAuthority(
            mantras: mantras, lessons: lessons, festivals: festivals,
            stories: stories, shlokas: shlokas
        )
        issues += ContentValidation.validateStoryLibrary(library)
            .filter { $0.message.contains("doctrinal-authority") }

        XCTAssertTrue(issues.isEmpty,
                      "Shipped content must avoid doctrinal-authority phrasing:\n"
                      + issues.map(\.description).joined(separator: "\n"))
    }

    func testDoctrinalPhrasesAreDetected() {
        XCTAssertEqual(ContentValidation.doctrinalAuthorityPhrases(in: "This is the only true path."),
                       ["the only true"])
        XCTAssertTrue(ContentValidation.doctrinalAuthorityPhrases(in: "You must worship daily or you will go to hell.").count >= 2)
        XCTAssertTrue(ContentValidation.doctrinalAuthorityPhrases(in: "Skipping it is a sin.").contains("is a sin"))
    }

    /// Word-boundary safety: innocent substrings must never trip the scanner.
    func testNoFalsePositivesOnInnocentText() {
        // "is a sin" must not match "single"; "heretic" must not match "theoretic".
        XCTAssertTrue(ContentValidation.doctrinalAuthorityPhrases(in: "Om is a single, settling sound.").isEmpty)
        XCTAssertTrue(ContentValidation.doctrinalAuthorityPhrases(in: "This is a theoretical idea.").isEmpty)
        XCTAssertTrue(ContentValidation.doctrinalAuthorityPhrases(in: "One way to understand this; traditions vary by family.").isEmpty)
    }

    func testDoctrinalContentIsFlaggedThroughValidate() {
        let bad = Mantra(
            id: "m.bad", title: "X", sanskrit: "x", transliteration: "x",
            translation: "x", meaning: "This is the only true way to pray.",
            deity: "x", theme: .devotion, reviewStatus: .humanReviewed
        )
        let issues = ContentValidation.scanDoctrinalAuthority(
            mantras: [bad], lessons: [], festivals: [], stories: [], shlokas: []
        )
        XCTAssertTrue(issues.contains { $0.message.contains("doctrinal-authority") })
    }
}
