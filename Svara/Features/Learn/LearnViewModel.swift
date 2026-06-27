import Foundation

@Observable
@MainActor
final class LearnViewModel {
    private(set) var lessons: [Lesson] = []
    private(set) var isLoading = true

    func load(content: ContentRepository) async {
        isLoading = true
        lessons = (await content.lessons()).sorted { $0.level < $1.level }
        isLoading = false
    }

    func completedCount(profile: UserProfile) -> Int {
        lessons.filter { profile.completedLessonIDs.contains($0.id) }.count
    }

    func progress(profile: UserProfile) -> Double {
        guard !lessons.isEmpty else { return 0 }
        return Double(completedCount(profile: profile)) / Double(lessons.count)
    }
}
