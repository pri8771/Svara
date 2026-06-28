import Foundation

/// A learner's answer to an interactive step.
enum LessonAnswer: Equatable {
    /// An index into a step's `options` (multipleChoice, matchMeaning, option-fillBlank).
    case option(Int)
    /// Free text typed/spoken by the learner (free-text fillBlank).
    case text(String)
    /// An ordering the learner built (syllableOrder).
    case ordering([String])
    /// No answer yet.
    case none
}

/// Pure, deterministic answer validation for lesson steps. Free of UI and
/// persistence so it can be unit-tested exhaustively.
///
/// Per ProductGuardrails §8.2, evaluation is **forgiving**: a non-matching
/// answer is never "wrong" or penalised — it simply isn't a match yet, and the
/// learner is shown the correct answer kindly and continues.
enum LessonEvaluator {

    /// Whether `answer` matches the correct answer for `step`.
    /// Non-scored steps (intro/listen/meaning/reflection) always return `true`.
    static func isCorrect(_ answer: LessonAnswer, for step: LessonStep) -> Bool {
        guard step.isScored else { return true }
        switch step.kind {
        case .multipleChoice, .matchMeaning:
            return matchesOption(answer, correctIndex: step.correctIndex)
        case .fillBlank:
            return matchesFillBlank(answer, step: step)
        case .syllableOrder:
            return matchesOrdering(answer, expected: step.syllables)
        case .intro, .listen, .meaning, .reflection:
            return true
        }
    }

    // MARK: - Per-kind matching

    private static func matchesOption(_ answer: LessonAnswer, correctIndex: Int?) -> Bool {
        guard let correctIndex, case let .option(i) = answer else { return false }
        return i == correctIndex
    }

    /// fillBlank accepts either a chosen option (legacy) or free text matched
    /// against `acceptedAnswers` (case- and whitespace-insensitive). When the
    /// step provides free-text answers, the correct option's text also counts.
    private static func matchesFillBlank(_ answer: LessonAnswer, step: LessonStep) -> Bool {
        switch answer {
        case let .option(i):
            if let correctIndex = step.correctIndex, i == correctIndex { return true }
            // Also accept an option whose text is an accepted answer.
            guard step.options.indices.contains(i) else { return false }
            return isAccepted(step.options[i], in: acceptedSet(for: step))
        case let .text(value):
            return isAccepted(value, in: acceptedSet(for: step))
        case .ordering, .none:
            return false
        }
    }

    private static func matchesOrdering(_ answer: LessonAnswer, expected: [String]) -> Bool {
        guard case let .ordering(given) = answer, !expected.isEmpty else { return false }
        guard given.count == expected.count else { return false }
        return zip(given, expected).allSatisfy { normalize($0) == normalize($1) }
    }

    // MARK: - Accepted-answer helpers

    /// The full set of accepted normalized strings for a fillBlank step:
    /// explicit `acceptedAnswers` plus the correct option's text if present.
    private static func acceptedSet(for step: LessonStep) -> Set<String> {
        var set = Set(step.acceptedAnswers.map(normalize))
        if let correctIndex = step.correctIndex, step.options.indices.contains(correctIndex) {
            set.insert(normalize(step.options[correctIndex]))
        }
        return set
    }

    private static func isAccepted(_ value: String, in set: Set<String>) -> Bool {
        !set.isEmpty && set.contains(normalize(value))
    }

    /// Normalises for forgiving comparison: lowercased, punctuation treated as a
    /// separator, and internal whitespace collapsed to single spaces.
    static func normalize(_ value: String) -> String {
        var chars: [Character] = []
        for scalar in value.lowercased().unicodeScalars {
            if CharacterSet.alphanumerics.contains(scalar) {
                chars.append(Character(scalar))
            } else {
                chars.append(" ")
            }
        }
        return String(chars)
            .split(separator: " ", omittingEmptySubsequences: true)
            .joined(separator: " ")
    }
}
