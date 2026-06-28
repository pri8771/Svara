import Foundation
import SwiftUI

@Observable
@MainActor
final class TodayViewModel {
    private(set) var practices: [DailyPractice] = []
    private(set) var mantraOfDay: Mantra?
    private(set) var lessons: [Lesson] = []
    private(set) var shloka: ShlokaOfDay?
    private(set) var isLoading = true

    private var mantras: [Mantra] = []

    func load(content: ContentRepository, now: Date = Date()) async {
        isLoading = true
        practices = await content.dailyPractices()
        mantras = await content.mantras()
        lessons = AarohPath.ordered(await content.lessons())
        shloka = await content.shlokaOfDay(for: now)
        mantraOfDay = pickMantraOfDay(from: mantras)
        isLoading = false
    }

    /// Today's recommended Aaroh step for the "continue Aaroh" card.
    func aarohRecommendation(completedIDs: Set<String>, inProgressIDs: Set<String>) -> LessonRecommendation {
        DailyRecommender.recommend(
            lessons: lessons,
            completedIDs: completedIDs,
            inProgressIDs: inProgressIDs,
            shloka: shloka
        )
    }

    func mantra(id: String?) -> Mantra? {
        guard let id else { return nil }
        return mantras.first { $0.id == id }
    }

    /// Practices ordered so the one most relevant to the current time is first.
    func orderedPractices(now: Date = Date()) -> [DailyPractice] {
        let currentBucket = TimeOfDay.from(hour: Calendar.current.component(.hour, from: now))
        return practices.sorted { lhs, rhs in
            rank(lhs.timeOfDay, current: currentBucket) < rank(rhs.timeOfDay, current: currentBucket)
        }
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch TimeOfDay.from(hour: hour) {
        case .morning: return "Good morning"
        case .afternoon: return "Good afternoon"
        case .evening: return "Good evening"
        case .night: return "Peaceful night"
        }
    }

    private func rank(_ time: TimeOfDay, current: TimeOfDay) -> Int {
        time == current ? 0 : 1
    }

    /// Deterministic "mantra of the day" so it's stable within a day.
    private func pickMantraOfDay(from mantras: [Mantra]) -> Mantra? {
        guard !mantras.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return mantras[day % mantras.count]
    }
}
