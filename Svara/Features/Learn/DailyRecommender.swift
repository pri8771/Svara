import Foundation

/// The single most relevant next thing for the learner to do today, plus a
/// human reason for why it's being suggested.
struct LessonRecommendation: Equatable {
    enum Reason: String, Equatable {
        /// Pick up a lesson already started.
        case continueInProgress
        /// The next unlocked lesson on the path.
        case nextUnlocked
        /// Brand-new learner — start at the very beginning.
        case firstBeginner
        /// Path finished — gently offer a revisit.
        case reviewCompleted
        /// Nothing learnable surfaced; point at the day's shloka instead.
        case shlokaRelated
    }

    let lesson: Lesson?
    let reason: Reason

    /// A short, gentle eyebrow describing the suggestion.
    var eyebrow: String {
        switch reason {
        case .continueInProgress: return LearnCopy.continueCardTitle
        case .nextUnlocked, .firstBeginner: return LearnCopy.nextStepEyebrow
        case .reviewCompleted: return LearnCopy.reviewEyebrow
        case .shlokaRelated: return "TODAY'S VERSE"
        }
    }
}

/// Chooses today's recommended next step. Pure and deterministic.
///
/// Priority (highest first), per Phase 2B spec:
/// 1. continue in-progress
/// 2. next unlocked (not yet completed)
/// 3. first beginner (nothing started yet)
/// 4. review completed (path finished)
/// 5. ShlokaOfDay related (fallback)
enum DailyRecommender {

    static func recommend(
        lessons: [Lesson],
        completedIDs: Set<String>,
        inProgressIDs: Set<String>,
        shloka: ShlokaOfDay? = nil
    ) -> LessonRecommendation {
        let order = AarohPath.ordered(lessons)

        // 1. Continue something already started (earliest in path order).
        if let inProgress = order.first(where: { inProgressIDs.contains($0.id) && !completedIDs.contains($0.id) }) {
            return LessonRecommendation(lesson: inProgress, reason: .continueInProgress)
        }

        // 2/3. The current unlocked, not-yet-completed lesson.
        if let current = AarohPath.current(in: lessons, completedIDs: completedIDs) {
            let nothingDoneYet = completedIDs.isEmpty && inProgressIDs.isEmpty
            return LessonRecommendation(
                lesson: current,
                reason: nothingDoneYet ? .firstBeginner : .nextUnlocked
            )
        }

        // 4. Everything is complete — offer the earliest lesson to revisit.
        if let first = order.first, !completedIDs.isEmpty {
            return LessonRecommendation(lesson: first, reason: .reviewCompleted)
        }

        // 5. No lessons at all — fall back to the shloka of the day.
        _ = shloka
        return LessonRecommendation(lesson: nil, reason: .shlokaRelated)
    }
}
