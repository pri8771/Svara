import Foundation

@Observable
@MainActor
final class ProfileViewModel {
    private(set) var achievements: [Achievement] = []
    private(set) var isLoading = true

    func load(content: ContentRepository) async {
        isLoading = true
        achievements = await content.achievements()
        isLoading = false
    }

    func unlockedCount(profile: UserProfile) -> Int {
        achievements.filter { profile.unlockedAchievementIDs.contains($0.id) }.count
    }
}
