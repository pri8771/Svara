import Foundation

/// The local representation of the signed-in user and all progress state.
/// Persisted locally and (when configured) synced to Firestore behind
/// `ContentRepository` / `ProgressService`.
struct UserProfile: Identifiable, Codable, Hashable {
    let id: String
    var displayName: String
    var email: String?
    var avatarSystemImage: String
    var joinedDate: Date

    // Gamification
    var currentStreak: Int
    var longestStreak: Int
    var totalPoints: Int
    var lastPracticeDate: Date?

    // Progress
    var completedSessionIDs: [String]
    var completedLessonIDs: [String]
    var observedFestivalIDs: [String]
    var unlockedAchievementIDs: [String]

    // Entitlement
    var isPremium: Bool

    // Preferences
    var notificationsEnabled: Bool
    var morningReminderHour: Int
    var eveningReminderHour: Int

    init(
        id: String = UUID().uuidString,
        displayName: String,
        email: String? = nil,
        avatarSystemImage: String = "person.crop.circle.fill",
        joinedDate: Date = Date(),
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        totalPoints: Int = 0,
        lastPracticeDate: Date? = nil,
        completedSessionIDs: [String] = [],
        completedLessonIDs: [String] = [],
        observedFestivalIDs: [String] = [],
        unlockedAchievementIDs: [String] = [],
        isPremium: Bool = false,
        notificationsEnabled: Bool = false,
        morningReminderHour: Int = 8,
        eveningReminderHour: Int = 20
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.avatarSystemImage = avatarSystemImage
        self.joinedDate = joinedDate
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalPoints = totalPoints
        self.lastPracticeDate = lastPracticeDate
        self.completedSessionIDs = completedSessionIDs
        self.completedLessonIDs = completedLessonIDs
        self.observedFestivalIDs = observedFestivalIDs
        self.unlockedAchievementIDs = unlockedAchievementIDs
        self.isPremium = isPremium
        self.notificationsEnabled = notificationsEnabled
        self.morningReminderHour = morningReminderHour
        self.eveningReminderHour = eveningReminderHour
    }

    /// True when this is an anonymous, local-only profile (no account). The app
    /// is fully usable as a guest — sign-in is optional and only adds an email.
    var isGuest: Bool { email == nil }

    /// A fresh guest profile used before sign-in / for previews.
    static func guest() -> UserProfile {
        UserProfile(
            id: "guest",
            displayName: "Friend",
            email: nil,
            avatarSystemImage: "person.crop.circle.fill"
        )
    }
}
