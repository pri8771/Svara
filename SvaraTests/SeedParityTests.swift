import XCTest
@testable import Svara

/// LB-1: the in-code `SeedContent` arrays are the offline fallback used when a
/// JSON seed file is missing or fails to decode. If the fallback drifts from the
/// shipped JSON, the app can silently serve a *different, smaller* catalogue than
/// QA tested. These tests assert the two sources stay in lock-step: same item
/// ids and the same count for every content type.
final class SeedParityTests: XCTestCase {

    private var provider: SeedContentProvider!

    override func setUp() {
        super.setUp()
        provider = SeedContentProvider(bundle: .main)
    }

    /// Asserts the JSON-decoded ids exactly match the in-code fallback ids.
    private func assertParity(
        _ label: String,
        json jsonIDs: [String],
        fallback fallbackIDs: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let jsonSet = Set(jsonIDs)
        let fallbackSet = Set(fallbackIDs)

        let onlyInJSON = jsonSet.subtracting(fallbackSet).sorted()
        let onlyInFallback = fallbackSet.subtracting(jsonSet).sorted()

        XCTAssertTrue(
            onlyInJSON.isEmpty,
            "\(label): ids in JSON but missing from in-code fallback: \(onlyInJSON)",
            file: file, line: line
        )
        XCTAssertTrue(
            onlyInFallback.isEmpty,
            "\(label): ids in in-code fallback but missing from JSON: \(onlyInFallback)",
            file: file, line: line
        )
        XCTAssertEqual(
            jsonIDs.count, fallbackIDs.count,
            "\(label): count mismatch — JSON \(jsonIDs.count) vs fallback \(fallbackIDs.count)",
            file: file, line: line
        )
        // No duplicate ids within either source.
        XCTAssertEqual(jsonSet.count, jsonIDs.count, "\(label): duplicate ids in JSON", file: file, line: line)
        XCTAssertEqual(fallbackSet.count, fallbackIDs.count, "\(label): duplicate ids in fallback", file: file, line: line)
    }

    func testMantraParity() throws {
        let json = try provider.decode([Mantra].self, from: "seed_mantras")
        assertParity("mantras", json: json.map(\.id), fallback: SeedContent.mantras.map(\.id))
    }

    func testLessonParity() throws {
        let json = try provider.decode([Lesson].self, from: "seed_lessons")
        assertParity("lessons", json: json.map(\.id), fallback: SeedContent.lessons.map(\.id))
    }

    func testFestivalParity() throws {
        let json = try provider.decode([Festival].self, from: "seed_festivals")
        assertParity("festivals", json: json.map(\.id), fallback: SeedContent.festivals.map(\.id))
    }

    func testStorySymbolParity() throws {
        let json = try provider.decode([StorySymbol].self, from: "seed_stories")
        assertParity("stories", json: json.map(\.id), fallback: SeedContent.stories.map(\.id))
    }

    func testShlokaParity() throws {
        let json = try provider.decode([ShlokaOfDay].self, from: "seed_shlokas")
        assertParity("shlokas", json: json.map(\.id), fallback: SeedContent.shlokas.map(\.id))
    }

    func testAchievementParity() throws {
        let json = try provider.decode([Achievement].self, from: "seed_achievements")
        assertParity("achievements", json: json.map(\.id), fallback: SeedContent.achievements.map(\.id))
    }

    func testStoryLibraryParity() throws {
        let json = try provider.decode([Story].self, from: "seed_story_library")
        assertParity("storyLibrary", json: json.map(\.id), fallback: SeedContent.storyLibrary.map(\.id))
    }

    /// Every shloka's `deepLinkTarget` (e.g. "mantra:mantra.om") must resolve to a
    /// real id present in *both* the JSON and the in-code fallback, so deep links
    /// never dangle regardless of which source is live.
    func testShlokaDeepLinksResolveInBothSources() throws {
        let jsonShlokas = try provider.decode([ShlokaOfDay].self, from: "seed_shlokas")
        let jsonMantras = try provider.decode([Mantra].self, from: "seed_mantras")
        let jsonLessons = try provider.decode([Lesson].self, from: "seed_lessons")

        let jsonMantraIDs = Set(jsonMantras.map(\.id))
        let jsonLessonIDs = Set(jsonLessons.map(\.id))
        let codeMantraIDs = Set(SeedContent.mantras.map(\.id))
        let codeLessonIDs = Set(SeedContent.lessons.map(\.id))

        for shloka in jsonShlokas {
            switch AppDeepLink.parse(shloka.deepLinkTarget) {
            case .mantra(let id):
                XCTAssertTrue(jsonMantraIDs.contains(id), "shloka \(shloka.id) deep-links to missing JSON mantra \(id)")
                XCTAssertTrue(codeMantraIDs.contains(id), "shloka \(shloka.id) deep-links to missing in-code mantra \(id)")
            case .lesson(let id):
                XCTAssertTrue(jsonLessonIDs.contains(id), "shloka \(shloka.id) deep-links to missing JSON lesson \(id)")
                XCTAssertTrue(codeLessonIDs.contains(id), "shloka \(shloka.id) deep-links to missing in-code lesson \(id)")
            case .tab, .story, .festival, .unknown:
                break
            }
        }
    }
}
