import Foundation

@Observable
@MainActor
final class ProfileViewModel {
    private(set) var achievements: [Achievement] = []
    private(set) var isLoading = true

    init(achievements: [Achievement] = []) {
        self.achievements = achievements
        isLoading = achievements.isEmpty
    }

    func load(content: ContentRepository) async {
        isLoading = true
        achievements = await content.achievements()
        isLoading = false
    }

    func unlockedCount(profile: UserProfile) -> Int {
        achievements.filter { profile.unlockedAchievementIDs.contains($0.id) }.count
    }

    func nextPointsMilestone(profile: UserProfile) -> Achievement? {
        achievements
            .filter(\.isPointsMilestone)
            .filter { $0.target > profile.totalPoints }
            .min { $0.target < $1.target }
    }
}
