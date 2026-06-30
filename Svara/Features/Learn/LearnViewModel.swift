import Foundation

/// A chapter of the Aaroh Path: one mantra and the lessons that teach it.
struct AarohChapter: Identifiable, Hashable {
    let id: String          // mantraID (or a synthetic key)
    let title: String
    let subtitle: String?
    let lessons: [Lesson]
}

@Observable
@MainActor
final class LearnViewModel {
    private(set) var lessons: [Lesson] = []
    private(set) var mantras: [Mantra] = []
    private(set) var shloka: ShlokaOfDay?
    private(set) var isLoading = true

    func load(content: ContentRepository, now: Date = Date()) async {
        isLoading = true
        lessons = AarohPath.ordered(await content.lessons())
        mantras = await content.mantras()
        shloka = await content.shlokaOfDay(for: now)
        isLoading = false
    }

    /// Lessons that sit on the guided beginner path (Days 1...N), in order.
    var pathLessons: [Lesson] {
        lessons.filter(\.isOnPath).sorted {
            ($0.pathDay ?? $0.level) < ($1.pathDay ?? $1.level)
        }
    }

    /// Lessons beyond the guided path (ordered by level).
    var beyondLessons: [Lesson] {
        lessons.filter { !$0.isOnPath }
    }

    /// Path lessons grouped into chapters by their mantra, preserving order.
    var chapters: [AarohChapter] {
        var order: [String] = []
        var grouped: [String: [Lesson]] = [:]
        for lesson in pathLessons {
            let key = lesson.mantraID ?? lesson.id
            if grouped[key] == nil { order.append(key) }
            grouped[key, default: []].append(lesson)
        }
        return order.map { key in
            let groupLessons = grouped[key] ?? []
            let mantra = mantras.first { $0.id == key }
            return AarohChapter(
                id: key,
                title: mantra?.title ?? groupLessons.first?.title ?? "Chapter",
                subtitle: mantra?.meaning ?? groupLessons.first?.meaningOverview,
                lessons: groupLessons
            )
        }
    }

    func completedCount(profile: UserProfile) -> Int {
        lessons.filter { profile.completedLessonIDs.contains($0.id) }.count
    }

    func pathCompletedCount(profile: UserProfile) -> Int {
        pathLessons.filter { profile.completedLessonIDs.contains($0.id) }.count
    }

    func progress(profile: UserProfile) -> Double {
        guard !lessons.isEmpty else { return 0 }
        return Double(completedCount(profile: profile)) / Double(lessons.count)
    }

    /// Today's single recommended step.
    func recommendation(completedIDs: Set<String>, inProgressIDs: Set<String>) -> LessonRecommendation {
        DailyRecommender.recommend(
            lessons: lessons,
            completedIDs: completedIDs,
            inProgressIDs: inProgressIDs,
            shloka: shloka
        )
    }
}
