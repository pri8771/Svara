import XCTest
@testable import Svara

/// Covers lesson answer validation for every interactive step type.
final class LessonEvaluatorTests: XCTestCase {

    // MARK: multipleChoice / matchMeaning

    func testMultipleChoiceMatching() {
        let step = LessonFactory.step("q", kind: .multipleChoice, options: ["A", "B", "C"], correctIndex: 1)
        XCTAssertTrue(LessonEvaluator.isCorrect(.option(1), for: step))
        XCTAssertFalse(LessonEvaluator.isCorrect(.option(0), for: step))
        XCTAssertFalse(LessonEvaluator.isCorrect(.none, for: step))
        XCTAssertFalse(LessonEvaluator.isCorrect(.text("B"), for: step))
    }

    func testMatchMeaningUsesCorrectIndex() {
        let step = LessonFactory.step("m", kind: .matchMeaning, options: ["Curved trunk", "Sun"], correctIndex: 0)
        XCTAssertTrue(LessonEvaluator.isCorrect(.option(0), for: step))
        XCTAssertFalse(LessonEvaluator.isCorrect(.option(1), for: step))
    }

    // MARK: fillBlank (option + free text)

    func testFillBlankWithOption() {
        let step = LessonFactory.step("f", kind: .fillBlank, options: ["Namaha", "Svaha"], correctIndex: 0)
        XCTAssertTrue(LessonEvaluator.isCorrect(.option(0), for: step))
        XCTAssertFalse(LessonEvaluator.isCorrect(.option(1), for: step))
    }

    func testFillBlankWithFreeTextAcceptedAnswers() {
        let step = LessonFactory.step("f", kind: .fillBlank,
                                      options: ["out-breath", "in-breath"], correctIndex: 0,
                                      acceptedAnswers: ["out breath", "exhale"])
        XCTAssertTrue(LessonEvaluator.isCorrect(.text("Out Breath"), for: step), "case/space-insensitive")
        XCTAssertTrue(LessonEvaluator.isCorrect(.text("exhale"), for: step))
        XCTAssertTrue(LessonEvaluator.isCorrect(.text("  EXHALE  "), for: step), "trims whitespace")
        XCTAssertFalse(LessonEvaluator.isCorrect(.text("in breath"), for: step))
        // The correct option's text is also accepted as free text.
        XCTAssertTrue(LessonEvaluator.isCorrect(.text("out-breath"), for: step))
    }

    func testFillBlankOptionWhoseTextIsAccepted() {
        let step = LessonFactory.step("f", kind: .fillBlank,
                                      options: ["exhale", "weekend"], correctIndex: nil,
                                      acceptedAnswers: ["exhale"])
        XCTAssertTrue(LessonEvaluator.isCorrect(.option(0), for: step))
        XCTAssertFalse(LessonEvaluator.isCorrect(.option(1), for: step))
    }

    // MARK: syllableOrder

    func testSyllableOrderExactSequence() {
        let step = LessonFactory.step("s", kind: .syllableOrder, syllables: ["vak", "ra", "tun", "da"])
        XCTAssertTrue(LessonEvaluator.isCorrect(.ordering(["vak", "ra", "tun", "da"]), for: step))
    }

    func testSyllableOrderWrongOrderIsNotMatched() {
        let step = LessonFactory.step("s", kind: .syllableOrder, syllables: ["vak", "ra", "tun", "da"])
        XCTAssertFalse(LessonEvaluator.isCorrect(.ordering(["ra", "vak", "tun", "da"]), for: step))
        XCTAssertFalse(LessonEvaluator.isCorrect(.ordering(["vak", "ra", "tun"]), for: step), "incomplete")
        XCTAssertFalse(LessonEvaluator.isCorrect(.option(0), for: step), "wrong answer type")
    }

    func testSyllableOrderIsCaseAndSpaceInsensitive() {
        let step = LessonFactory.step("s", kind: .syllableOrder, syllables: ["Na", "mas"])
        XCTAssertTrue(LessonEvaluator.isCorrect(.ordering([" na ", "MAS"]), for: step))
    }

    // MARK: Non-scored steps

    func testNonScoredStepsAlwaysPass() {
        for kind in [LessonStep.Kind.intro, .listen, .meaning, .reflection] {
            let step = LessonFactory.step("n", kind: kind)
            XCTAssertTrue(LessonEvaluator.isCorrect(.none, for: step), "\(kind) should never be 'wrong'")
        }
    }

    func testNormalizeCollapsesAndLowercases() {
        XCTAssertEqual(LessonEvaluator.normalize("  Out   Breath  "), "out breath")
        XCTAssertEqual(LessonEvaluator.normalize("You!"), "you")
    }
}
