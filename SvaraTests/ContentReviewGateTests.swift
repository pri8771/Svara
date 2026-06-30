import XCTest
@testable import Svara

/// LB-3: nothing ships to users as devotional fact without human review. The
/// gate requires every user-facing item to be `humanReviewed` or `sourced`
/// (Story uses the string "reviewed"). These tests prove the gate is enforced —
/// both that the shipped catalogue passes it and that an unreviewed item fails.
final class ContentReviewGateTests: XCTestCase {

    private var provider: SeedContentProvider!

    override func setUp() {
        super.setUp()
        provider = SeedContentProvider(bundle: .main)
    }

    func testEveryShippedItemIsReviewed() throws {
        let mantras = try provider.decode([Mantra].self, from: "seed_mantras")
        let lessons = try provider.decode([Lesson].self, from: "seed_lessons")
        let festivals = try provider.decode([Festival].self, from: "seed_festivals")
        let stories = try provider.decode([StorySymbol].self, from: "seed_stories")
        let shlokas = try provider.decode([ShlokaOfDay].self, from: "seed_shlokas")
        let library = try provider.decode([Story].self, from: "seed_story_library")

        var issues: [ValidationIssue] = []
        issues += ContentValidation.validateReviewed(mantras, type: "mantra")
        issues += ContentValidation.validateReviewed(lessons, type: "lesson")
        issues += ContentValidation.validateReviewed(festivals, type: "festival")
        issues += ContentValidation.validateReviewed(stories, type: "story")
        issues += ContentValidation.validateReviewed(shlokas, type: "shloka")
        issues += ContentValidation.validateStoryLibrary(library)

        XCTAssertTrue(
            issues.isEmpty,
            "Every shipped item must be reviewed:\n" + issues.map(\.description).joined(separator: "\n")
        )
    }

    func testUnreviewedItemIsFlagged() {
        let draft = Mantra(
            id: "mantra.unreviewed", title: "Draft", sanskrit: "x",
            transliteration: "x", translation: "x", meaning: "x",
            deity: "x", theme: .devotion, reviewStatus: nil
        )
        let issues = ContentValidation.validateReviewed([draft], type: "mantra")
        XCTAssertEqual(issues.count, 1)
        XCTAssertTrue(issues.first?.message.contains("not cleared for shipping") ?? false)
    }

    func testDraftStatusIsNotReviewed() {
        XCTAssertFalse(ContentReviewStatus.draft.isReviewed)
        XCTAssertFalse(ContentReviewStatus.aiDrafted.isReviewed)
        XCTAssertTrue(ContentReviewStatus.humanReviewed.isReviewed)
        XCTAssertTrue(ContentReviewStatus.sourced.isReviewed)
    }

    func testDraftStoryIsFlagged() {
        let story = Story(
            id: "s", deity: "d", title: "t", theme: .wisdom, durationMinutes: 3,
            bodyMarkdown: "body", moralOrMeaning: "m", symbolism: [],
            reflectionPrompt: "r", relatedMantraId: nil, relatedFestivalId: nil,
            traditionNote: "varies", sourceName: "src", sourceNote: "note",
            reviewStatus: "draft", region: [], tags: []
        )
        let issues = ContentValidation.validateStory(story)
        XCTAssertTrue(issues.contains { $0.message.contains("reviewStatus must be 'reviewed'") })
    }
}
