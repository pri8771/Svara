import Foundation

/// Centralised, reviewed copy for the Learn / Aaroh experience.
///
/// Keeping the strings in one place lets `LearnCopyTests` assert that:
/// 1. forbidden, punitive words ("wrong", "failed", "incorrect", "you lost",
///    "don't break your streak", "lives", "hearts") never appear, and
/// 2. the gentle, encouraging phrasings required by product review are present.
///
/// See ProductGuardrails §5 (Copywriting) and §8.2 (Learn tab — no "lives").
enum LearnCopy {

    // MARK: - Gentle correction (shown when an answer isn't the match)
    //
    // Never "wrong"/"incorrect"/"failed". We acknowledge effort and invite
    // another gentle attempt.

    static let gentleCorrections: [String] = [
        "Almost — here's a hint.",
        "You're building familiarity, not chasing perfection.",
        "Try that once more.",
        "One sound at a time."
    ]

    /// A stable gentle correction for a given attempt (cycles, never random so
    /// it stays calm and predictable).
    static func gentleCorrection(forAttempt attempt: Int) -> String {
        guard !gentleCorrections.isEmpty else { return "" }
        let index = max(0, attempt) % gentleCorrections.count
        return gentleCorrections[index]
    }

    // MARK: - Affirmation (shown when an answer matches)

    static let affirmations: [String] = [
        "That's it.",
        "Beautifully done.",
        "You've got it.",
        "Lovely."
    ]

    static func affirmation(forIndex index: Int) -> String {
        guard !affirmations.isEmpty else { return "" }
        return affirmations[max(0, index) % affirmations.count]
    }

    // MARK: - Humble meaning framing (ProductGuardrails §7)

    static let translationFraming = "One common translation…"
    static let understandingFraming = "One way to understand this…"
    static let traditionFraming = "Traditions vary by family and region."

    // MARK: - Empty state (new learner)

    static let emptyStateTitle = "Your path begins here"
    static let emptyStateMessage = "Start with a single sound. Each short step takes about a minute — come back tomorrow for the next one."
    static let emptyStateCTA = "Begin Day 1"

    // MARK: - Path / next-step

    static let pathEyebrow = "AAROH PATH"
    static let nextStepEyebrow = "TODAY'S NEXT STEP"
    static let continueCardTitle = "Continue your Aaroh"
    static let reviewEyebrow = "REVISIT"
    static let allCaughtUpTitle = "You're all caught up"
    static let allCaughtUpMessage = "You've finished today's path. Revisit a lesson, or return tomorrow for what's next."

    // MARK: - Result screen

    static let lessonCompleteTitle = "Step complete"
    static let comeBackTomorrow = "Come back tomorrow for the next step on your path."
    static let unlockedPrefix = "You unlocked:"

    /// "You unlocked: What Vakratunda means"
    static func unlockedLine(_ insightTitle: String) -> String {
        "\(unlockedPrefix) \(insightTitle)"
    }

    // MARK: - Step instructions

    static let tapToReveal = "Tap to reveal a hint"
    static let chantAlong = "Chant along softly"
    static let arrangeSyllables = "Tap the syllables in order"
    static let typeOrTap = "Choose the word that completes it"
}
