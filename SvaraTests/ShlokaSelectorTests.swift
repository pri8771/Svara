import XCTest
@testable import Svara

final class ShlokaSelectorTests: XCTestCase {

    private let calendar = Calendar(identifier: .gregorian)
    private var shlokas: [ShlokaOfDay] { SeedContent.shlokas }

    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        calendar.date(from: DateComponents(year: y, month: m, day: d))!
    }

    func testSelectionIsDeterministicForSameDay() {
        let day = date(2026, 6, 27)
        let a = ShlokaSelector.shloka(for: day, from: shlokas, calendar: calendar)
        let b = ShlokaSelector.shloka(for: day, from: shlokas, calendar: calendar)
        XCTAssertNotNil(a)
        XCTAssertEqual(a, b, "Same calendar day must yield the same shloka")
    }

    func testSelectionIsStableAcrossSameDateDifferentTimes() {
        let morning = calendar.date(from: DateComponents(year: 2026, month: 6, day: 27, hour: 6))!
        let evening = calendar.date(from: DateComponents(year: 2026, month: 6, day: 27, hour: 22))!
        XCTAssertEqual(
            ShlokaSelector.shloka(for: morning, from: shlokas, calendar: calendar),
            ShlokaSelector.shloka(for: evening, from: shlokas, calendar: calendar)
        )
    }

    func testConsecutiveDaysRotate() {
        // With a catalogue larger than 1, consecutive day-of-year values map to
        // different indices.
        let d1 = date(2026, 1, 1)
        let d2 = date(2026, 1, 2)
        XCTAssertNotEqual(
            ShlokaSelector.shloka(for: d1, from: shlokas, calendar: calendar)?.id,
            ShlokaSelector.shloka(for: d2, from: shlokas, calendar: calendar)?.id
        )
    }

    func testPinnedDateKeyWins() {
        var pool = shlokas
        let pinned = ShlokaOfDay(
            id: "shloka.pinned", transliteration: "t", translation: "x",
            meaning: "m", theme: .devotion, dateKey: "12-25",
            deepLinkTarget: "today"
        )
        pool.append(pinned)
        let christmas = date(2026, 12, 25)
        XCTAssertEqual(ShlokaSelector.shloka(for: christmas, from: pool, calendar: calendar)?.id, "shloka.pinned")
    }

    func testEmptyCatalogueReturnsNil() {
        XCTAssertNil(ShlokaSelector.shloka(for: date(2026, 6, 27), from: [], calendar: calendar))
    }

    func testDeepLinkParsing() {
        XCTAssertEqual(AppDeepLink.parse("today"), .tab(.today))
        XCTAssertEqual(AppDeepLink.parse("mantra:mantra.om"), .mantra("mantra.om"))
        XCTAssertEqual(AppDeepLink.parse("story:story.hanuman.courage"), .story("story.hanuman.courage"))
        XCTAssertEqual(AppDeepLink.parse("lesson:lesson.gayatri.basics"), .lesson("lesson.gayatri.basics"))
        if case .unknown = AppDeepLink.parse("nonsense:foo") {
            // expected
        } else {
            XCTFail("Unknown deep link kind should parse to .unknown")
        }
    }
}
