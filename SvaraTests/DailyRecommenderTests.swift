import XCTest
@testable import Svara

/// Covers the daily recommendation priority:
/// continue in-progress → next unlocked → first beginner → review completed → shloka.
final class DailyRecommenderTests: XCTestCase {

    private let lessons = [
        LessonFactory.lesson("a", level: 1, pathDay: 1),
        LessonFactory.lesson("b", level: 2, pathDay: 2),
        LessonFactory.lesson("c", level: 3, pathDay: 3)
    ]

    func testFirstBeginnerWhenNothingStarted() {
        let rec = DailyRecommender.recommend(lessons: lessons, completedIDs: [], inProgressIDs: [])
        XCTAssertEqual(rec.reason, .firstBeginner)
        XCTAssertEqual(rec.lesson?.id, "a")
    }

    func testContinueInProgressTakesPriority() {
        // 'b' is in progress and 'a' is complete: continue 'b' over starting 'c'.
        let rec = DailyRecommender.recommend(lessons: lessons, completedIDs: ["a"], inProgressIDs: ["b"])
        XCTAssertEqual(rec.reason, .continueInProgress)
        XCTAssertEqual(rec.lesson?.id, "b")
    }

    func testInProgressBeatsNextEvenFromStart() {
        let rec = DailyRecommender.recommend(lessons: lessons, completedIDs: [], inProgressIDs: ["a"])
        XCTAssertEqual(rec.reason, .continueInProgress)
        XCTAssertEqual(rec.lesson?.id, "a")
    }

    func testNextUnlockedWhenSomethingCompletedButNoneInProgress() {
        let rec = DailyRecommender.recommend(lessons: lessons, completedIDs: ["a"], inProgressIDs: [])
        XCTAssertEqual(rec.reason, .nextUnlocked)
        XCTAssertEqual(rec.lesson?.id, "b")
    }

    func testReviewCompletedWhenPathFinished() {
        let rec = DailyRecommender.recommend(lessons: lessons, completedIDs: ["a", "b", "c"], inProgressIDs: [])
        XCTAssertEqual(rec.reason, .reviewCompleted)
        XCTAssertEqual(rec.lesson?.id, "a")
    }

    func testShlokaFallbackWhenNoLessons() {
        let rec = DailyRecommender.recommend(lessons: [], completedIDs: [], inProgressIDs: [])
        XCTAssertEqual(rec.reason, .shlokaRelated)
        XCTAssertNil(rec.lesson)
    }
}
