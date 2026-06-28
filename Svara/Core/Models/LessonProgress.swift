import Foundation

/// Per-lesson progress. Phase 1 tracked only a flat list of completed lesson
/// ids on `UserProfile`; this richer model captures step-level progress and
/// best score so the Learn tab can resume and show mastery over time.
///
/// Per product review: **no "lives"/hearts mechanic.** Progress is additive and
/// forgiving — a wrong answer never costs anything; `hintsUsed` simply records
/// how much help was needed.
///
/// Firebase mapping (future): subcollection `users/{uid}/lessonProgress`,
/// document id = `lessonID`.
struct LessonProgress: Identifiable, Codable, Hashable {
    var id: String { lessonID }
    let lessonID: String
    /// Ids of `LessonStep`s the learner has completed.
    var completedStepIDs: [String]
    var isCompleted: Bool
    /// Best number of quiz steps answered correctly in a single run.
    var bestCorrectCount: Int
    /// Total quiz steps in the lesson, for computing a score.
    var totalQuizCount: Int
    var attempts: Int
    /// Number of hints the learner has revealed (gentle hint system).
    var hintsUsed: Int
    var lastAccessed: Date?

    init(
        lessonID: String,
        completedStepIDs: [String] = [],
        isCompleted: Bool = false,
        bestCorrectCount: Int = 0,
        totalQuizCount: Int = 0,
        attempts: Int = 0,
        hintsUsed: Int = 0,
        lastAccessed: Date? = nil
    ) {
        self.lessonID = lessonID
        self.completedStepIDs = completedStepIDs
        self.isCompleted = isCompleted
        self.bestCorrectCount = bestCorrectCount
        self.totalQuizCount = totalQuizCount
        self.attempts = attempts
        self.hintsUsed = hintsUsed
        self.lastAccessed = lastAccessed
    }

    /// Best score as a fraction (0...1); 1 when there are no quiz steps.
    var bestScoreFraction: Double {
        guard totalQuizCount > 0 else { return isCompleted ? 1 : 0 }
        return min(1, Double(bestCorrectCount) / Double(totalQuizCount))
    }

    /// Started but not yet finished — drives the "continue where you left off"
    /// recommendation on Today and Learn.
    var isInProgress: Bool { !isCompleted && !completedStepIDs.isEmpty }
}
