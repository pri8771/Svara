import XCTest
@testable import Svara

/// Guards the Learn experience's tone:
/// 1. No punitive / shame-based words in any Learn-facing string.
/// 2. No forbidden Primandir-style feature terms.
/// 3. The required gentle corrections and humble framings are present.
final class LearnCopyTests: XCTestCase {

    /// Words that must never appear in Learn copy (ProductGuardrails §5, §8.2).
    private let forbiddenWords: Set<String> = [
        "wrong", "incorrect", "failed", "fail", "lose", "lost", "lives", "hearts", "shame"
    ]
    /// Phrases that must never appear.
    private let forbiddenPhrases: [String] = [
        "you lost", "don't break your streak", "break your streak", "you failed"
    ]

    private func words(in text: String) -> Set<String> {
        Set(text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty })
    }

    /// Every user-facing string used by the Learn surface.
    private func learnStrings() -> [String] {
        var strings: [String] = []
        strings += LearnCopy.gentleCorrections
        strings += LearnCopy.affirmations
        strings += [
            LearnCopy.translationFraming, LearnCopy.understandingFraming, LearnCopy.traditionFraming,
            LearnCopy.emptyStateTitle, LearnCopy.emptyStateMessage, LearnCopy.emptyStateCTA,
            LearnCopy.pathEyebrow, LearnCopy.nextStepEyebrow, LearnCopy.continueCardTitle,
            LearnCopy.reviewEyebrow, LearnCopy.allCaughtUpTitle, LearnCopy.allCaughtUpMessage,
            LearnCopy.lessonCompleteTitle, LearnCopy.comeBackTomorrow, LearnCopy.unlockedPrefix,
            LearnCopy.tapToReveal, LearnCopy.chantAlong, LearnCopy.arrangeSyllables, LearnCopy.typeOrTap,
            LearnCopy.unlockedLine("What Vakratunda means")
        ]
        // All authored lesson content (titles, steps, insights, provenance notes).
        for lesson in SeedContent.lessons {
            strings += [lesson.title, lesson.subtitle]
            strings += [lesson.meaningOverview, lesson.pronunciationTip,
                        lesson.insightTitle, lesson.insightBody,
                        lesson.traditionNote, lesson.sourceNote].compactMap { $0 }
            for step in lesson.steps {
                strings.append(step.prompt)
                if let detail = step.detail { strings.append(detail) }
                strings += step.options
            }
        }
        return strings
    }

    func testNoPunitiveWordsInLearnCopy() {
        for string in learnStrings() {
            let tokens = words(in: string)
            let hits = tokens.intersection(forbiddenWords)
            XCTAssertTrue(hits.isEmpty, "Punitive word(s) \(hits) found in: \"\(string)\"")
        }
    }

    func testNoPunitivePhrasesInLearnCopy() {
        for string in learnStrings() {
            let lower = string.lowercased()
            for phrase in forbiddenPhrases {
                XCTAssertFalse(lower.contains(phrase), "Forbidden phrase \"\(phrase)\" found in: \"\(string)\"")
            }
        }
    }

    func testNoForbiddenPrimandirTermsInLearnCopy() {
        for string in learnStrings() {
            let found = ContentValidation.forbiddenTerms(in: string)
            XCTAssertTrue(found.isEmpty, "Forbidden term(s) \(found) found in: \"\(string)\"")
        }
    }

    func testRequiredGentleCorrectionsPresent() {
        let expected = [
            "Almost — here's a hint.",
            "You're building familiarity, not chasing perfection.",
            "Try that once more.",
            "One sound at a time."
        ]
        for line in expected {
            XCTAssertTrue(LearnCopy.gentleCorrections.contains(line), "missing gentle correction: \(line)")
        }
    }

    func testRequiredHumbleFramingsPresent() {
        XCTAssertEqual(LearnCopy.translationFraming, "One common translation…")
        XCTAssertEqual(LearnCopy.understandingFraming, "One way to understand this…")
        XCTAssertEqual(LearnCopy.traditionFraming, "Traditions vary by family and region.")
    }

    func testGentleCorrectionCyclesSafely() {
        XCTAssertEqual(LearnCopy.gentleCorrection(forAttempt: 0), "Almost — here's a hint.")
        // Negative / large indices never crash and stay in range.
        XCTAssertFalse(LearnCopy.gentleCorrection(forAttempt: -3).isEmpty)
        XCTAssertFalse(LearnCopy.gentleCorrection(forAttempt: 99).isEmpty)
    }

    func testUnlockedLineFormatsCorrectly() {
        XCTAssertEqual(LearnCopy.unlockedLine("What Vakratunda means"),
                       "You unlocked: What Vakratunda means")
    }

    /// The humble framings actually appear in the shipped path content.
    func testSeedPathUsesHumbleFramings() {
        let allInsight = SeedContent.lessons.compactMap { $0.insightBody }.joined(separator: " ")
        XCTAssertTrue(allInsight.contains("One way to understand this"))
        XCTAssertTrue(allInsight.contains("One common translation"))
        XCTAssertTrue(allInsight.contains("Traditions vary by family and region"))
    }
}
