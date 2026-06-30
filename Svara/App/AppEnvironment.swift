import Foundation
import SwiftUI

/// The single composition root for Svara. Owns every service (behind its
/// protocol) and the observable session/profile state that views read from.
/// Injected into the view tree via `.environment(...)`.
@Observable
@MainActor
final class AppEnvironment {

    // MARK: Services (protocol-typed for swappability)
    let auth: AuthService
    let content: ContentRepository
    let progress: ProgressService
    let notifications: NotificationService
    let store: StoreService

    /// Phase 2D Stories & Symbols library (Story model) and private reflections.
    let storyLibrary: StoriesService
    let reflections: ReflectionStore

    /// Which primary surfaces are active (full product vs. staged beta scope).
    let featureFlags: FeatureFlags

    private let kvStore: KeyValueStore

    // MARK: Session state
    var profile: UserProfile
    var isAuthenticated: Bool = false
    var hasCompletedOnboarding: Bool

    /// Achievements unlocked since the last time the UI presented them — drives
    /// the celebratory toast.
    var pendingAchievements: [Achievement] = []

    /// Effective premium entitlement: an active purchase or a stored flag.
    var isPremium: Bool { store.isPlus || profile.isPremium }

    init(
        auth: AuthService,
        content: ContentRepository,
        progress: ProgressService,
        notifications: NotificationService,
        store: StoreService,
        kvStore: KeyValueStore,
        featureFlags: FeatureFlags = .current
    ) {
        self.auth = auth
        self.content = content
        self.progress = progress
        self.notifications = notifications
        self.store = store
        self.storyLibrary = StoriesService()
        self.reflections = ReflectionStore()
        self.featureFlags = featureFlags
        self.kvStore = kvStore
        self.profile = .guest()
        self.hasCompletedOnboarding = kvStore.load(Bool.self, forKey: StorageKey.onboardingComplete) ?? false
    }

    // MARK: - Factories

    static func live() -> AppEnvironment {
        let kv = UserDefaultsStore()
        return AppEnvironment(
            auth: MockAuthService(store: kv),
            content: LocalContentRepository(),
            progress: LocalProgressService(store: kv),
            notifications: LocalNotificationService(),
            store: StoreService(),
            kvStore: kv
        )
    }

    /// An environment pre-populated for SwiftUI previews.
    static func preview(premium: Bool = false) -> AppEnvironment {
        let kv = UserDefaultsStore(defaults: UserDefaults(suiteName: "svara.preview") ?? .standard)
        let env = AppEnvironment(
            auth: MockAuthService(store: kv),
            content: LocalContentRepository(),
            progress: LocalProgressService(store: kv),
            notifications: LocalNotificationService(),
            store: StoreService(),
            kvStore: kv
        )
        env.profile = UserProfile(
            displayName: "Ananya",
            email: "ananya@example.com",
            currentStreak: 5,
            longestStreak: 12,
            totalPoints: 340,
            isPremium: premium
        )
        env.isAuthenticated = true
        env.hasCompletedOnboarding = true
        return env
    }

    // MARK: - Lifecycle

    /// Restores any saved session and warms up StoreKit products. If there is no
    /// saved session, establishes a local **guest** so the app opens straight
    /// into content with no account required (LB-2 / "no account to start").
    func bootstrap() async {
        if let restored = await auth.restoreSession() {
            profile = restored
            isAuthenticated = true
        } else {
            await continueAsGuest()
        }
        await store.loadProducts()
    }

    func signIn(email: String, password: String) async throws {
        let user = try await auth.signIn(email: email, password: password)
        profile = user
        isAuthenticated = true
    }

    func register(displayName: String, email: String, password: String) async throws {
        let user = try await auth.register(displayName: displayName, email: email, password: password)
        profile = user
        isAuthenticated = true
    }

    func continueAsGuest() async {
        if let user = try? await auth.signInAnonymously() {
            profile = user
            isAuthenticated = true
        }
    }

    /// Signs out of an account and drops back to a fresh local guest — never to
    /// an auth wall. The app stays open and usable.
    func signOut() async {
        try? await auth.signOut()
        notifications.cancelAllReminders()
        await continueAsGuest()
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        kvStore.save(true, forKey: StorageKey.onboardingComplete)
    }

    // MARK: - Progress mutations

    func completePractice(_ practice: DailyPractice, durationSeconds: Int) {
        let session = PracticeSession(
            practiceID: practice.id,
            practiceTitle: practice.title,
            kind: practice.kind,
            durationSeconds: durationSeconds,
            pointsEarned: practice.points
        )
        let (updated, unlocked) = progress.recordSession(session, for: profile)
        apply(updated, unlocked: unlocked)
    }

    /// Records a single lesson step as the learner moves through it (resume +
    /// hint tracking). Never awards points.
    func recordLessonStep(_ step: LessonStep, in lesson: Lesson, wasCorrect: Bool?, hintUsed: Bool) {
        progress.recordStep(
            lessonID: lesson.id,
            stepID: step.id,
            wasCorrect: wasCorrect,
            hintUsed: hintUsed,
            totalQuizCount: lesson.quizCount
        )
    }

    /// Completes a lesson: finalises step-level progress (best score) and awards
    /// points/streak exactly once via the unified progress rules.
    func completeLesson(_ lesson: Lesson, correctCount: Int = 0) {
        progress.finalizeLessonProgress(
            lessonID: lesson.id,
            correctCount: correctCount,
            totalQuizCount: lesson.quizCount
        )
        let (updated, unlocked) = progress.completeLesson(lesson, for: profile)
        apply(updated, unlocked: unlocked)
    }

    // MARK: - Lesson progress reads

    func lessonProgress(for lesson: Lesson) -> LessonProgress? {
        progress.lessonProgress(for: lesson.id)
    }

    /// Lesson ids that are started but not finished.
    var inProgressLessonIDs: Set<String> {
        Set(progress.loadLessonProgress().filter(\.isInProgress).map(\.lessonID))
    }

    /// Lesson ids the learner has completed (authoritative on the profile).
    var completedLessonIDs: Set<String> {
        Set(profile.completedLessonIDs)
    }

    func observeFestival(_ festival: Festival) {
        let (updated, unlocked) = progress.observeFestival(festival, for: profile)
        apply(updated, unlocked: unlocked)
    }

    /// Completes a festival's tiny activity, awarding its points exactly once
    /// (falls back to 15 when the festival has no explicit activity points).
    func completeFestivalActivity(_ festival: Festival) {
        let points = festival.tinyActivity?.points ?? 15
        let (updated, unlocked) = progress.completeFestivalActivity(festival, points: points, for: profile)
        apply(updated, unlocked: unlocked)
    }

    /// Whether the festival's activity has been completed (reuses the observed
    /// ledger as the completion record).
    func hasCompletedFestivalActivity(_ festival: Festival) -> Bool {
        profile.observedFestivalIDs.contains(festival.id)
    }

    func hasCompletedPractice(_ practice: DailyPractice) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return progress.loadSessions().contains {
            $0.practiceID == practice.id && Calendar.current.startOfDay(for: $0.date) == today
        }
    }

    func isLessonCompleted(_ lesson: Lesson) -> Bool {
        profile.completedLessonIDs.contains(lesson.id)
    }

    func isFestivalObserved(_ festival: Festival) -> Bool {
        profile.observedFestivalIDs.contains(festival.id)
    }

    func isAchievementUnlocked(_ achievement: Achievement) -> Bool {
        profile.unlockedAchievementIDs.contains(achievement.id)
    }

    // MARK: - Preferences

    func updateNotificationPreferences(enabled: Bool, morningHour: Int, eveningHour: Int) async {
        profile.notificationsEnabled = enabled
        profile.morningReminderHour = morningHour
        profile.eveningReminderHour = eveningHour
        persistProfile()

        if enabled {
            let granted = await notifications.requestAuthorization()
            if granted {
                await notifications.scheduleDailyReminders(morningHour: morningHour, eveningHour: eveningHour)
            } else {
                profile.notificationsEnabled = false
                persistProfile()
            }
        } else {
            notifications.cancelAllReminders()
        }
    }

    func setPremium(_ value: Bool) {
        profile.isPremium = value
        persistProfile()
    }

    // MARK: - Helpers

    private func apply(_ updated: UserProfile, unlocked: [Achievement]) {
        profile = updated
        persistProfile()
        if !unlocked.isEmpty {
            pendingAchievements.append(contentsOf: unlocked)
        }
    }

    func persistProfile() {
        kvStore.save(profile, forKey: StorageKey.userProfile)
    }

    func clearPendingAchievements() {
        pendingAchievements.removeAll()
    }
}
