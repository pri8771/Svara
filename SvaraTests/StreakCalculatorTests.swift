import XCTest
@testable import Svara

/// `StreakCalculator` is pure and central to the gamification posture (gentle,
/// forgiving streaks). It previously had no test despite that. These cover the
/// documented rules: same-day no-op, consecutive-day increment, gap reset, and
/// the first-ever practice.
final class StreakCalculatorTests: XCTestCase {

    private let cal = Calendar(identifier: .gregorian)

    private func day(_ y: Int, _ m: Int, _ d: Int, hour: Int = 9) -> Date {
        cal.date(from: DateComponents(year: y, month: m, day: d, hour: hour))!
    }

    func testFirstEverPracticeStartsAtOne() {
        XCTAssertEqual(StreakCalculator.updatedStreak(current: 0, lastPracticeDate: nil, now: day(2026, 6, 30), calendar: cal), 1)
    }

    func testSamedaySecondPracticeDoesNotChangeStreak() {
        let r = StreakCalculator.updatedStreak(
            current: 4, lastPracticeDate: day(2026, 6, 30, hour: 7),
            now: day(2026, 6, 30, hour: 21), calendar: cal)
        XCTAssertEqual(r, 4, "A second practice on the same day must not change the streak.")
    }

    func testConsecutiveDayIncrements() {
        let r = StreakCalculator.updatedStreak(
            current: 4, lastPracticeDate: day(2026, 6, 30),
            now: day(2026, 7, 1), calendar: cal)
        XCTAssertEqual(r, 5)
    }

    func testGapOfTwoDaysResetsToOne() {
        let r = StreakCalculator.updatedStreak(
            current: 9, lastPracticeDate: day(2026, 6, 28),
            now: day(2026, 6, 30), calendar: cal)
        XCTAssertEqual(r, 1, "A missed day is a gentle fresh start, not a continuation.")
    }

    func testSameDayWithZeroCurrentBecomesAtLeastOne() {
        let r = StreakCalculator.updatedStreak(
            current: 0, lastPracticeDate: day(2026, 6, 30, hour: 6),
            now: day(2026, 6, 30, hour: 20), calendar: cal)
        XCTAssertEqual(r, 1)
    }

    func testCrossMonthConsecutiveDayIncrements() {
        let r = StreakCalculator.updatedStreak(
            current: 2, lastPracticeDate: day(2026, 6, 30),
            now: day(2026, 7, 1), calendar: cal)
        XCTAssertEqual(r, 3, "30 June → 1 July is consecutive.")
    }
}
