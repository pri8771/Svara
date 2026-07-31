import Foundation
import SwiftUI

/// The single composition root for Svara. Owns every service (behind its
/// protocol) and the observable session/profile state that views read from.
/// Injected into the view tree via `.environment(...)`.
@Observable
@MainActor
final class AppEnvironment {

    // MARK: Services (protocol-typed for swappability)
    let profileSession: ProfileSessionService
    let content: ContentRepository
    let progress: ProgressService
    let notifications: NotificationService
    let store: StoreService
    /// Plays bundled mantra audio (chant-along) from the practice and lesson players.
    let audioPlayback = AudioPlaybackService()

    /// Phase 2D Stories & Symbols library (Story model) and private reflections.
    let storyLibrary: StoriesService
    let reflections: ReflectionStore

    /// Which primary surfaces are active (full product vs. staged beta scope).
    let featureFlags: FeatureFlags

    /// Cross-tab navigation / deep-link routing (e.g. shloka-of-the-day links).
    let navigation = NavigationCoordinator()

    private let kvStore: KeyValueStore

    // MARK: Session state
    var profile: UserProfile
    var isAuthenticated: Bool = false
    var hasCompletedOnboarding: Bool

    /// Achievements unlocked since the last time the UI presented them — drives
    /// the celebratory toast.
    var pendingAchievements: [Achievement] = []

    /// Festivals the user has bookmarked — persisted locally.
    var savedFestivalIDs: Set<String> = []

    /// StoreKit is the sole authority for premium access. A profile flag cannot
    /// outlive an expired, refunded, or revoked transaction.
    var isPremium: Bool { store.isPlus }

    /// Whether the dormant Plus experience is intentionally exposed.
    var isPlusTierEnabled: Bool { featureFlags.plusTierEnabled }

    /// Premium markers remain authored for a future paid release, but they do
    /// not restrict content while the owner-only testing build is free.
    func isLockedBehindPlus(_ lesson: Lesson) -> Bool {
        isPlusTierEnabled && lesson.isPremium && !isPremium
    }

    init(
        profileSession: ProfileSessionService,
        content: ContentRepository,
        progress: ProgressService,
        notifications: NotificationService,
        store: StoreService,
        kvStore: KeyValueStore,
        featureFlags: FeatureFlags = .current
    ) {
        self.profileSession = profileSession
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
        self.savedFestivalIDs = kvStore.load(Set<String>.self, forKey: StorageKey.savedFestivalIDs) ?? []
    }

    // MARK: - Factories

    static func live() -> AppEnvironment {
        let defaults = UserDefaults.standard
        if ProcessInfo.processInfo.arguments.contains("-UITestResetState") {
            // Deterministic starting point for XCUITest: wipe everything the app
            // persists so each UI test run begins at onboarding with a 0-day streak,
            // regardless of what a previous run left behind on this simulator.
            for key in [
                StorageKey.userProfile,
                StorageKey.sessions,
                StorageKey.onboardingComplete,
                StorageKey.lessonProgress,
                StorageKey.savedFestivalIDs
            ] {
                defaults.removeObject(forKey: key)
            }
        }
        let kv = UserDefaultsStore(defaults: defaults)
        return AppEnvironment(
            profileSession: LocalProfileSessionService(store: kv),
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
            profileSession: LocalProfileSessionService(store: kv),
            content: LocalContentRepository(),
            progress: LocalProgressService(store: kv),
            notifications: LocalNotificationService(),
            store: StoreService(
                previewPurchasedProductIDs: premium ? [SvaraProductID.lifetime] : []
            ),
            kvStore: kv
        )
        env.profile = UserProfile(
            displayName: "Ananya",
            email: nil,
            currentStreak: 5,
            longestStreak: 12,
            totalPoints: 340,
            isPremium: false
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
        if let restored = await profileSession.restoreProfile() {
            profile = restored
            clearLegacyAccountState()
            isAuthenticated = true
        } else {
            await establishLocalProfile()
        }
        let (reconciled, newlyUnlocked) = progress.reconcileAchievements(for: profile)
        apply(reconciled, unlocked: newlyUnlocked)
        if isPlusTierEnabled {
            await store.loadProducts()
        }
    }

    func establishLocalProfile() async {
        profile = await profileSession.createProfileIfNeeded()
        clearLegacyAccountState()
        isAuthenticated = true
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        kvStore.save(true, forKey: StorageKey.onboardingComplete)
#if DEBUG
        // XCUITest terminates the process immediately after this transition.
        // Flush only in that harness so the forced termination cannot race the
        // preferences daemon; production keeps normal asynchronous UserDefaults.
        if ProcessInfo.processInfo.arguments.contains("-UITestResetState") {
            UserDefaults.standard.synchronize()
        }
#endif
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
    @discardableResult
    func completeLesson(_ lesson: Lesson, correctCount: Int = 0) -> Bool {
        let earnsPoints = !profile.completedLessonIDs.contains(lesson.id)
        progress.finalizeLessonProgress(
            lessonID: lesson.id,
            correctCount: correctCount,
            totalQuizCount: lesson.quizCount
        )
        let (updated, unlocked) = progress.completeLesson(lesson, for: profile)
        apply(updated, unlocked: unlocked)
        return earnsPoints
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

    func isFestivalSaved(_ festival: Festival) -> Bool {
        savedFestivalIDs.contains(festival.id)
    }

    func toggleFestivalSaved(_ festival: Festival) {
        if savedFestivalIDs.contains(festival.id) {
            savedFestivalIDs.remove(festival.id)
        } else {
            savedFestivalIDs.insert(festival.id)
        }
        kvStore.save(savedFestivalIDs, forKey: StorageKey.savedFestivalIDs)
    }

    func isAchievementUnlocked(_ achievement: Achievement) -> Bool {
        profile.unlockedAchievementIDs.contains(achievement.id)
    }

    // MARK: - Preferences

    @discardableResult
    func updateNotificationPreferences(enabled: Bool, morningHour: Int, eveningHour: Int) async -> Bool {
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
                return false
            }
        } else {
            notifications.cancelAllReminders()
        }
        return true
    }

    func updateDisplayName(_ displayName: String) {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        profile.displayName = trimmed
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

    func clearPendingAchievement(_ achievement: Achievement) {
        pendingAchievements.removeAll { $0.id == achievement.id }
    }

    /// Migrates profiles created by the former local mock sign-in. That UI
    /// accepted arbitrary credentials and could persist premium access, so
    /// neither field is trusted by the production app.
    private func clearLegacyAccountState() {
        guard profile.email != nil || profile.isPremium else { return }
        profile.email = nil
        profile.isPremium = false
        persistProfile()
    }
}
