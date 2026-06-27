import Foundation

/// Pure, testable streak math. Kept free of persistence and dates-of-"now"
/// where possible so it can be unit-tested deterministically.
enum StreakCalculator {
    /// Returns the new streak value given the last practice date and "today".
    /// - A practice on the same day leaves the streak unchanged.
    /// - A practice the day after `lastPracticeDate` increments it.
    /// - Any longer gap (or no prior practice) resets the streak to 1.
    static func updatedStreak(
        current: Int,
        lastPracticeDate: Date?,
        now: Date,
        calendar: Calendar = .current
    ) -> Int {
        guard let last = lastPracticeDate else { return 1 }
        let lastDay = calendar.startOfDay(for: last)
        let today = calendar.startOfDay(for: now)
        let days = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        switch days {
        case 0: return max(current, 1) // already practiced today
        case 1: return current + 1      // consecutive day
        default: return 1               // streak broken
        }
    }
}

/// Records practice/lesson/festival progress, awards Svara Points and streaks,
/// and unlocks achievements. Operates on a `UserProfile` and persists results.
protocol ProgressService {
    /// Records a completed practice session and returns the updated profile.
    func recordSession(_ session: PracticeSession, for profile: UserProfile) -> (UserProfile, [Achievement])
    /// Marks a lesson complete (idempotent) and returns the updated profile.
    func completeLesson(_ lesson: Lesson, for profile: UserProfile) -> (UserProfile, [Achievement])
    /// Marks a festival as observed and returns the updated profile.
    func observeFestival(_ festival: Festival, for profile: UserProfile) -> (UserProfile, [Achievement])
    /// Newly-unlocked achievements relative to what's already unlocked.
    func evaluateAchievements(for profile: UserProfile, catalogue: [Achievement]) -> [Achievement]
    /// Progress (0...1) toward an achievement for display.
    func progress(for achievement: Achievement, profile: UserProfile) -> Double

    func loadSessions() -> [PracticeSession]
}

final class LocalProgressService: ProgressService {
    private let store: KeyValueStore
    private let achievementsCatalogue: [Achievement]
    private let now: () -> Date

    init(store: KeyValueStore, achievements: [Achievement] = SeedContent.achievements, now: @escaping () -> Date = { Date() }) {
        self.store = store
        self.achievementsCatalogue = achievements
        self.now = now
    }

    // MARK: Sessions

    func loadSessions() -> [PracticeSession] {
        store.load([PracticeSession].self, forKey: StorageKey.sessions) ?? []
    }

    private func append(_ session: PracticeSession) {
        var sessions = loadSessions()
        sessions.append(session)
        store.save(sessions, forKey: StorageKey.sessions)
    }

    // MARK: Recording

    func recordSession(_ session: PracticeSession, for profile: UserProfile) -> (UserProfile, [Achievement]) {
        var updated = profile
        let today = now()

        updated.currentStreak = StreakCalculator.updatedStreak(
            current: profile.currentStreak,
            lastPracticeDate: profile.lastPracticeDate,
            now: today
        )
        updated.longestStreak = max(updated.longestStreak, updated.currentStreak)
        updated.lastPracticeDate = today
        updated.totalPoints += session.pointsEarned
        updated.completedSessionIDs.append(session.id)

        append(session)
        return applyAchievements(to: updated)
    }

    func completeLesson(_ lesson: Lesson, for profile: UserProfile) -> (UserProfile, [Achievement]) {
        var updated = profile
        guard !updated.completedLessonIDs.contains(lesson.id) else {
            return (updated, [])
        }
        updated.completedLessonIDs.append(lesson.id)
        updated.totalPoints += lesson.xp
        // Lessons also count as a practice for streak purposes.
        updated.currentStreak = StreakCalculator.updatedStreak(
            current: profile.currentStreak,
            lastPracticeDate: profile.lastPracticeDate,
            now: now()
        )
        updated.longestStreak = max(updated.longestStreak, updated.currentStreak)
        updated.lastPracticeDate = now()
        return applyAchievements(to: updated)
    }

    func observeFestival(_ festival: Festival, for profile: UserProfile) -> (UserProfile, [Achievement]) {
        var updated = profile
        guard !updated.observedFestivalIDs.contains(festival.id) else {
            return (updated, [])
        }
        updated.observedFestivalIDs.append(festival.id)
        updated.totalPoints += 15
        return applyAchievements(to: updated)
    }

    // MARK: Achievements

    private func applyAchievements(to profile: UserProfile) -> (UserProfile, [Achievement]) {
        var updated = profile
        let newly = evaluateAchievements(for: updated, catalogue: achievementsCatalogue)
        for achievement in newly {
            updated.unlockedAchievementIDs.append(achievement.id)
            updated.totalPoints += achievement.bonusPoints
        }
        return (updated, newly)
    }

    func evaluateAchievements(for profile: UserProfile, catalogue: [Achievement]) -> [Achievement] {
        catalogue.filter { achievement in
            !profile.unlockedAchievementIDs.contains(achievement.id)
                && meets(achievement.requirement, profile: profile)
        }
    }

    private func meets(_ requirement: Achievement.Requirement, profile: UserProfile) -> Bool {
        switch requirement {
        case .streakDays(let n): return profile.currentStreak >= n
        case .totalPractices(let n): return profile.completedSessionIDs.count >= n
        case .totalPoints(let n): return profile.totalPoints >= n
        case .lessonsCompleted(let n): return profile.completedLessonIDs.count >= n
        case .festivalsObserved(let n): return profile.observedFestivalIDs.count >= n
        }
    }

    func progress(for achievement: Achievement, profile: UserProfile) -> Double {
        let current: Int
        switch achievement.requirement {
        case .streakDays: current = profile.currentStreak
        case .totalPractices: current = profile.completedSessionIDs.count
        case .totalPoints: current = profile.totalPoints
        case .lessonsCompleted: current = profile.completedLessonIDs.count
        case .festivalsObserved: current = profile.observedFestivalIDs.count
        }
        guard achievement.target > 0 else { return 1 }
        return min(1, Double(current) / Double(achievement.target))
    }
}
