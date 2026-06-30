import XCTest
@testable import Svara

/// Covers the Aaroh Path unlock logic and node states.
final class AarohPathTests: XCTestCase {

    private let lessons = [
        LessonFactory.lesson("a", level: 1, pathDay: 1),
        LessonFactory.lesson("b", level: 2, pathDay: 2),
        LessonFactory.lesson("c", level: 3, pathDay: 3)
    ]

    func testFirstLessonAlwaysUnlocked() {
        XCTAssertTrue(AarohPath.isUnlocked(lessons[0], in: lessons, completedIDs: []))
        XCTAssertFalse(AarohPath.isUnlocked(lessons[1], in: lessons, completedIDs: []))
        XCTAssertFalse(AarohPath.isUnlocked(lessons[2], in: lessons, completedIDs: []))
    }

    func testCompletingUnlocksTheNext() {
        let completed: Set<String> = ["a"]
        XCTAssertTrue(AarohPath.isUnlocked(lessons[1], in: lessons, completedIDs: completed))
        XCTAssertFalse(AarohPath.isUnlocked(lessons[2], in: lessons, completedIDs: completed))
    }

    func testCurrentIsFirstUnlockedIncomplete() {
        XCTAssertEqual(AarohPath.current(in: lessons, completedIDs: [])?.id, "a")
        XCTAssertEqual(AarohPath.current(in: lessons, completedIDs: ["a"])?.id, "b")
        XCTAssertEqual(AarohPath.current(in: lessons, completedIDs: ["a", "b"])?.id, "c")
        XCTAssertNil(AarohPath.current(in: lessons, completedIDs: ["a", "b", "c"]))
    }

    func testNodeStates() {
        let completed: Set<String> = ["a"]
        XCTAssertEqual(AarohPath.state(for: lessons[0], in: lessons, completedIDs: completed), .completed)
        XCTAssertEqual(AarohPath.state(for: lessons[1], in: lessons, completedIDs: completed), .current)
        XCTAssertEqual(AarohPath.state(for: lessons[2], in: lessons, completedIDs: completed), .locked)
    }

    func testNextLessonAfter() {
        XCTAssertEqual(AarohPath.nextLesson(after: lessons[0], in: lessons)?.id, "b")
        XCTAssertEqual(AarohPath.nextLesson(after: lessons[1], in: lessons)?.id, "c")
        XCTAssertNil(AarohPath.nextLesson(after: lessons[2], in: lessons))
    }

    func testOrderingIsByLevelRegardlessOfInputOrder() {
        let shuffled = [lessons[2], lessons[0], lessons[1]]
        XCTAssertEqual(AarohPath.ordered(shuffled).map(\.id), ["a", "b", "c"])
    }

    func testSeedPathHasSevenDaysInOrder() {
        let path = SeedContent.lessons.filter(\.isOnPath).sorted { ($0.pathDay ?? 0) < ($1.pathDay ?? 0) }
        XCTAssertEqual(path.count, 7, "first beginner path is 7 days")
        XCTAssertEqual(path.map { $0.pathDay }, [1, 2, 3, 4, 5, 6, 7])
        // Om → Vakratunda → Saraswati Namastubhyam
        XCTAssertEqual(path.first?.mantraID, "mantra.om")
        XCTAssertEqual(path.last?.mantraID, "mantra.saraswatiNamastubhyam")
        XCTAssertTrue(path.contains { $0.mantraID == "mantra.vakratunda" })
    }

    func testEverySeedPathLessonHasInsightAndProvenance() {
        for lesson in SeedContent.lessons.filter(\.isOnPath) {
            XCTAssertNotNil(lesson.insightTitle, "\(lesson.id) missing insightTitle")
            XCTAssertNotNil(lesson.insightBody, "\(lesson.id) missing insightBody")
            XCTAssertNotNil(lesson.meaningOverview, "\(lesson.id) missing meaningOverview")
            XCTAssertNotNil(lesson.pronunciationTip, "\(lesson.id) missing pronunciationTip")
            XCTAssertNotNil(lesson.reviewStatus, "\(lesson.id) missing reviewStatus")
        }
    }
}
