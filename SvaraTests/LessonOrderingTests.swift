import XCTest
@testable import Svara

final class LessonOrderingTests: XCTestCase {

    private func lesson(_ id: String, level: Int) -> Lesson {
        Lesson(id: id, title: id, subtitle: "", theme: .wisdom, level: level,
               steps: [LessonStep(id: "\(id).s1", kind: .intro, prompt: "p")])
    }

    func testSeedLessonsAreValidlyOrdered() {
        let issues = ContentValidation.validateLessonOrder(SeedContent.lessons)
        XCTAssertTrue(issues.isEmpty, issues.map(\.description).joined(separator: "\n"))
        // Levels are unique and ascending in the seed set.
        let levels = SeedContent.lessons.map(\.level)
        XCTAssertEqual(levels, levels.sorted())
        XCTAssertEqual(Set(levels).count, levels.count)
    }

    func testDuplicateLevelsAreFlagged() {
        let lessons = [lesson("a", level: 1), lesson("b", level: 1)]
        let issues = ContentValidation.validateLessonOrder(lessons)
        XCTAssertTrue(issues.contains { $0.message.contains("duplicate level 1") })
    }

    func testNonPositiveLevelIsFlagged() {
        let lessons = [lesson("a", level: 0)]
        let issues = ContentValidation.validateLessonOrder(lessons)
        XCTAssertTrue(issues.contains { $0.message.contains("level must be >= 1") })
    }
}
