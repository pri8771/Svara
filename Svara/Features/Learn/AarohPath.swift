import Foundation

/// The visual state of a lesson node on the Aaroh Path.
enum LessonNodeState: String, Equatable {
    /// Finished by the learner.
    case completed
    /// The next available step — the one to do now.
    case current
    /// Available to start but not the immediate next (e.g. revisiting ahead is
    /// blocked; only the current step is open).
    case locked
}

/// Pure logic for the guided Aaroh Path: which lesson is unlocked, which is the
/// current step, and the node state of each lesson. No UI, no persistence.
///
/// Unlock rule (gentle, linear): the first lesson is always open; every other
/// lesson opens once the lesson immediately before it (in path order) is
/// completed. Premium entitlement is handled separately by the UI — a premium
/// lesson that is otherwise unlocked still routes to the paywall.
enum AarohPath {

    /// Lessons in canonical path order (by level, ascending).
    static func ordered(_ lessons: [Lesson]) -> [Lesson] {
        lessons.sorted { $0.level < $1.level }
    }

    /// Whether `lesson` is unlocked given the set of completed lesson ids.
    static func isUnlocked(
        _ lesson: Lesson,
        in lessons: [Lesson],
        completedIDs: Set<String>
    ) -> Bool {
        let order = ordered(lessons)
        guard let index = order.firstIndex(where: { $0.id == lesson.id }) else { return false }
        if index == 0 { return true }
        if completedIDs.contains(lesson.id) { return true }
        let previous = order[index - 1]
        return completedIDs.contains(previous.id)
    }

    /// The node state for `lesson`.
    /// - completed: in `completedIDs`.
    /// - current: the first non-completed unlocked lesson in path order.
    /// - locked: everything else.
    static func state(
        for lesson: Lesson,
        in lessons: [Lesson],
        completedIDs: Set<String>
    ) -> LessonNodeState {
        if completedIDs.contains(lesson.id) { return .completed }
        if current(in: lessons, completedIDs: completedIDs)?.id == lesson.id { return .current }
        return .locked
    }

    /// The single "current" lesson: the first lesson in path order that is
    /// unlocked but not yet completed. `nil` when the whole path is finished.
    static func current(
        in lessons: [Lesson],
        completedIDs: Set<String>
    ) -> Lesson? {
        ordered(lessons).first { lesson in
            !completedIDs.contains(lesson.id)
                && isUnlocked(lesson, in: lessons, completedIDs: completedIDs)
        }
    }

    /// The lesson unlocked *by* completing `lesson` (the next one in path order),
    /// if any. Used for the "Next lesson unlocks" message on the result screen.
    static func nextLesson(
        after lesson: Lesson,
        in lessons: [Lesson]
    ) -> Lesson? {
        let order = ordered(lessons)
        guard let index = order.firstIndex(where: { $0.id == lesson.id }),
              order.indices.contains(index + 1) else { return nil }
        return order[index + 1]
    }
}
