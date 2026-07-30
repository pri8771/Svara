import Foundation

/// The local profile and progress state. Svara 1.0 has no account or cloud
/// identity; this value is persisted only on the device.
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

    // Legacy migration field. StoreKit is the only entitlement authority.
    // Keep decoding this property so profiles from pre-1.0 builds migrate.
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

    /// True when this is an anonymous, local-only profile (no account).
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
