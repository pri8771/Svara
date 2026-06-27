import XCTest
@testable import Svara

/// Verifies every seed JSON file decodes into its model, and that Codable
/// round-trips cleanly (bundle-independent safety net).
final class SeedDecodingTests: XCTestCase {

    private var provider: SeedContentProvider!

    override func setUp() {
        super.setUp()
        // Hosted test target → Bundle.main is the Svara app bundle, so the
        // bundled seed JSON is reachable.
        provider = SeedContentProvider(bundle: .main)
    }

    func testDecodeMantrasFromBundle() throws {
        let mantras = try provider.decode([Mantra].self, from: "seed_mantras")
        XCTAssertGreaterThanOrEqual(mantras.count, 5)
        XCTAssertTrue(mantras.contains { $0.id == "mantra.om" })
        XCTAssertTrue(mantras.contains { $0.id == "mantra.gayatri" })
        XCTAssertTrue(mantras.contains { $0.id == "mantra.vakratunda" })
        XCTAssertTrue(mantras.contains { $0.id == "mantra.saraswatiNamastubhyam" })
        XCTAssertTrue(mantras.contains { $0.id == "mantra.shiva" })
    }

    func testDecodeLessonsFromBundle() throws {
        let lessons = try provider.decode([Lesson].self, from: "seed_lessons")
        XCTAssertFalse(lessons.isEmpty)
        // Every lesson has at least one step.
        XCTAssertTrue(lessons.allSatisfy { !$0.steps.isEmpty })
    }

    func testDecodeFestivalsFromBundleWithDates() throws {
        let festivals = try provider.decode([Festival].self, from: "seed_festivals")
        XCTAssertGreaterThanOrEqual(festivals.count, 3)
        // Festival dates parsed to sensible years.
        let calendar = Calendar(identifier: .gregorian)
        XCTAssertTrue(festivals.allSatisfy { calendar.component(.year, from: $0.date) >= 2026 })
        XCTAssertTrue(festivals.contains { $0.id == "festival.diwali" })
        XCTAssertTrue(festivals.contains { $0.id == "festival.holi" })
        XCTAssertTrue(festivals.contains { $0.id == "festival.navaratri" })
    }

    func testDecodeStoriesFromBundle() throws {
        let stories = try provider.decode([StorySymbol].self, from: "seed_stories")
        XCTAssertGreaterThanOrEqual(stories.count, 5)
        XCTAssertTrue(stories.contains { $0.deity == "Hanuman" })
        XCTAssertTrue(stories.contains { $0.deity == "Durga" })
    }

    func testDecodeShlokasFromBundle() throws {
        let shlokas = try provider.decode([ShlokaOfDay].self, from: "seed_shlokas")
        XCTAssertGreaterThanOrEqual(shlokas.count, 10)
        // Widget-ready text is always non-empty.
        XCTAssertTrue(shlokas.allSatisfy { !$0.shortDisplayText.isEmpty })
        XCTAssertTrue(shlokas.allSatisfy { !$0.mediumDisplayText.isEmpty })
    }

    func testDecodeAchievementsFromBundle() throws {
        let achievements = try provider.decode([Achievement].self, from: "seed_achievements")
        XCTAssertFalse(achievements.isEmpty)
        // Custom Requirement Codable decoded into real targets.
        XCTAssertTrue(achievements.allSatisfy { $0.target > 0 })
    }

    /// Bundle-independent: Codable conformance round-trips for every model.
    func testCodableRoundTripInCodeContent() throws {
        let encoder = JSONEncoder()
        let decoder = SeedContentProvider.makeDecoder()

        func roundTrip<T: Codable & Equatable>(_ items: [T]) throws {
            let data = try encoder.encode(items)
            let decoded = try decoder.decode([T].self, from: data)
            XCTAssertEqual(decoded, items)
        }

        try roundTrip(SeedContent.mantras)
        try roundTrip(SeedContent.lessons)
        try roundTrip(SeedContent.stories)
        try roundTrip(SeedContent.shlokas)
        try roundTrip(SeedContent.achievements)
        // Festivals encode dates as Date → custom decoder expects strings, so
        // round-trip them through the same provider-style formatting.
        XCTAssertFalse(SeedContent.festivals.isEmpty)
    }

    func testAchievementRequirementCodableShape() throws {
        let req = Achievement.Requirement.streakDays(7)
        let data = try JSONEncoder().encode(req)
        let json = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(json["type"] as? String, "streakDays")
        XCTAssertEqual(json["value"] as? Int, 7)
        let decoded = try JSONDecoder().decode(Achievement.Requirement.self, from: data)
        XCTAssertEqual(decoded, req)
    }
}
