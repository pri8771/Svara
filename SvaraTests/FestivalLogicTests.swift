import XCTest
@testable import Svara

/// Covers festival countdown, seasonal grouping, and gentle region filtering.
final class FestivalLogicTests: XCTestCase {

    // MARK: Helpers

    private func festival(_ id: String, daysFromNow: Int, regions: [String] = []) -> Festival {
        let date = Calendar.current.date(byAdding: .day, value: daysFromNow, to: Date())!
        return Festival(
            id: id, name: id, date: date, tagline: "t",
            significance: "s", story: "story", activities: [], theme: .prosperity,
            regionTags: regions
        )
    }

    // MARK: Countdown

    func testCountdownLabels() {
        XCTAssertEqual(FestivalCountdown.label(daysUntil: -1), "Passed")
        XCTAssertEqual(FestivalCountdown.label(daysUntil: 0), "Today")
        XCTAssertEqual(FestivalCountdown.label(daysUntil: 1), "Tomorrow")
        XCTAssertEqual(FestivalCountdown.label(daysUntil: 3), "in 3 days")
        XCTAssertEqual(FestivalCountdown.label(daysUntil: 7), "in 1 week")
        XCTAssertEqual(FestivalCountdown.label(daysUntil: 20), "in 20 days")
        XCTAssertTrue(FestivalCountdown.isToday(daysUntil: 0))
        XCTAssertFalse(FestivalCountdown.isToday(daysUntil: 1))
    }

    func testDaysUntilCalculation() {
        let f = festival("x", daysFromNow: 5)
        XCTAssertEqual(f.daysUntil(), 5)
        XCTAssertTrue(f.isUpcoming())
        let past = festival("y", daysFromNow: -2)
        XCTAssertEqual(past.daysUntil(), -2)
        XCTAssertFalse(past.isUpcoming())
    }

    func testDateDecodingFromISOString() throws {
        let json = """
        [{"id":"f","name":"F","date":"2026-11-08","tagline":"t","significance":"s","story":"st","activities":[],"theme":"prosperity"}]
        """.data(using: .utf8)!
        let decoded = try SeedContentProvider.makeDecoder().decode([Festival].self, from: json)
        let cal = Calendar(identifier: .gregorian)
        XCTAssertEqual(cal.component(.year, from: decoded[0].date), 2026)
        XCTAssertEqual(cal.component(.month, from: decoded[0].date), 11)
        XCTAssertEqual(cal.component(.day, from: decoded[0].date), 8)
    }

    // MARK: Seasons

    func testSeasonMapping() {
        XCTAssertEqual(FestivalSeason.season(forMonth: 1), .winter)
        XCTAssertEqual(FestivalSeason.season(forMonth: 3), .spring)
        XCTAssertEqual(FestivalSeason.season(forMonth: 6), .summer)
        XCTAssertEqual(FestivalSeason.season(forMonth: 8), .monsoon)
        XCTAssertEqual(FestivalSeason.season(forMonth: 10), .autumn)
    }

    func testThisSeasonWindow() {
        let soon = festival("soon", daysFromNow: 5)
        let mid = festival("mid", daysFromNow: 40)
        let far = festival("far", daysFromNow: 200)
        let past = festival("past", daysFromNow: -3)
        let result = FestivalSeasonGrouping.thisSeason([far, mid, soon, past], windowDays: 92)
        XCTAssertEqual(result.map(\.id), ["soon", "mid"], "within window, soonest first; far + past excluded")
    }

    // MARK: Region filtering (gentle, non-blocking)

    func testRegionFilterNeverHidesFestivals() {
        let all = [
            festival("a", daysFromNow: 1, regions: ["southIndia"]),
            festival("b", daysFromNow: 2, regions: ["northIndia"]),
            festival("c", daysFromNow: 3, regions: [])
        ]
        // No filter: order unchanged, nothing hidden.
        XCTAssertEqual(FestivalRegionFilter.ordered(all, for: nil).map(\.id), ["a", "b", "c"])
        // With a filter: same count (no hiding), matching floated to front.
        let south = FestivalRegionFilter.ordered(all, for: .southIndia)
        XCTAssertEqual(south.count, all.count, "filtering must never remove festivals")
        XCTAssertEqual(Set(south.map(\.id)), Set(["a", "b", "c"]))
        XCTAssertEqual(south.first?.id, "a", "matching festival floats to the front")
    }

    func testRegionMatching() {
        let south = festival("s", daysFromNow: 1, regions: ["southIndia"])
        let untagged = festival("u", daysFromNow: 1, regions: [])
        let diasporaOnly = festival("d", daysFromNow: 1, regions: ["diaspora"])

        XCTAssertTrue(FestivalRegionFilter.matches(untagged, region: .northIndia), "no tags = universally relevant")
        XCTAssertTrue(FestivalRegionFilter.matches(south, region: .southIndia))
        XCTAssertFalse(FestivalRegionFilter.matches(south, region: .northIndia))
        XCTAssertTrue(FestivalRegionFilter.matches(south, region: .india), "India is broad")
        XCTAssertTrue(FestivalRegionFilter.matches(diasporaOnly, region: .diaspora))
        XCTAssertFalse(FestivalRegionFilter.matches(diasporaOnly, region: .india))
    }
}
