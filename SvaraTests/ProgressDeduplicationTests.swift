import XCTest
@testable import Svara

/// Covers the unified progress rules: points awarded once per lesson, streaks
/// capped at once per local day, and lesson-progress best-score tracking.
final class ProgressDeduplicationTests: XCTestCase {

    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        var c = DateComponents(); c.year = y; c.month = m; c.day = d; c.hour = 9
        return Calendar.current.date(from: c)!
    }

    private func makeService(now: @escaping () -> Date) -> LocalProgressService {
        LocalProgressService(store: InMemoryStore(), achievements: [], now: now)
    }

    // MARK: Points dedup

    func testLessonPointsAwardedOnlyOnce() {
        let svc = makeService(now: { self.date(2026, 6, 28) })
        let lesson = LessonFactory.lesson("x", level: 1) // default xp 20
        let profile = UserProfile.guest()

        let (p1, _) = svc.completeLesson(lesson, for: profile)
        XCTAssertEqual(p1.totalPoints, lesson.xp)
        XCTAssertEqual(p1.completedLessonIDs, ["x"])

        let (p2, _) = svc.completeLesson(lesson, for: p1)
        XCTAssertEqual(p2.totalPoints, lesson.xp, "second completion must not re-award points")
        XCTAssertEqual(p2.completedLessonIDs.count, 1)
    }

    func testDistinctLessonsEachAwardOnce() {
        let svc = makeService(now: { self.date(2026, 6, 28) })
        let l1 = LessonFactory.lesson("l1", level: 1)
        let l2 = LessonFactory.lesson("l2", level: 2)

        let (p1, _) = svc.completeLesson(l1, for: .guest())
        let (p2, _) = svc.completeLesson(l2, for: p1)
        XCTAssertEqual(p2.totalPoints, l1.xp + l2.xp)
        XCTAssertEqual(Set(p2.completedLessonIDs), ["l1", "l2"])
    }

    func testSamePracticeAwardsAndPersistsOnlyOncePerLocalDay() {
        let today = date(2026, 6, 28)
        let svc = makeService(now: { today })
        let first = PracticeSession(
            practiceID: "morning",
            practiceTitle: "Morning Mantra",
            kind: .mantra,
            durationSeconds: 60,
            pointsEarned: 10
        )
        let repeatSession = PracticeSession(
            practiceID: "morning",
            practiceTitle: "Morning Mantra",
            kind: .mantra,
            durationSeconds: 90,
            pointsEarned: 10
        )

        let (p1, _) = svc.recordSession(first, for: .guest())
        let (p2, achievements) = svc.recordSession(repeatSession, for: p1)

        XCTAssertEqual(p2.totalPoints, 10)
        XCTAssertEqual(p2.completedSessionIDs, [first.id])
        XCTAssertEqual(svc.loadSessions().map(\.id), [first.id])
        XCTAssertTrue(achievements.isEmpty)
    }

    func testDifferentPracticesCanEachAwardOnTheSameDay() {
        let svc = makeService(now: { self.date(2026, 6, 28) })
        let morning = PracticeSession(practiceID: "morning", practiceTitle: "Morning",
                                      kind: .mantra, durationSeconds: 60, pointsEarned: 10)
        let evening = PracticeSession(practiceID: "evening", practiceTitle: "Evening",
                                      kind: .mantra, durationSeconds: 60, pointsEarned: 15)

        let (p1, _) = svc.recordSession(morning, for: .guest())
        let (p2, _) = svc.recordSession(evening, for: p1)

        XCTAssertEqual(p2.totalPoints, 25)
        XCTAssertEqual(svc.loadSessions().count, 2)
    }

    func testAchievementBonusUnlocksPointsMilestoneInSameTransaction() {
        let firstPractice = Achievement(
            id: "first",
            title: "First",
            detail: "Complete one practice.",
            systemImage: "figure.walk",
            requirement: .totalPractices(1),
            bonusPoints: 90
        )
        let pointsMilestone = Achievement(
            id: "points100",
            title: "Practice Spark",
            detail: "Earn 100 points.",
            systemImage: "sparkles",
            requirement: .totalPoints(100),
            bonusPoints: 0
        )
        let svc = LocalProgressService(
            store: InMemoryStore(),
            achievements: [firstPractice, pointsMilestone],
            now: { self.date(2026, 6, 28) }
        )
        let session = PracticeSession(
            practiceID: "morning",
            practiceTitle: "Morning",
            kind: .mantra,
            durationSeconds: 60,
            pointsEarned: 10
        )

        let (profile, unlocked) = svc.recordSession(session, for: .guest())

        XCTAssertEqual(profile.totalPoints, 100)
        XCTAssertEqual(unlocked.map(\.id), ["first", "points100"])
        XCTAssertEqual(Set(profile.unlockedAchievementIDs), ["first", "points100"])
    }

    func testReconcileUnlocksNewMilestonesForExistingPoints() {
        let milestones = [100, 250, 500].map { target in
            Achievement(
                id: "points\(target)",
                title: "Points \(target)",
                detail: "Earn \(target) points.",
                systemImage: "sparkles",
                requirement: .totalPoints(target),
                bonusPoints: 0
            )
        }
        let svc = LocalProgressService(
            store: InMemoryStore(),
            achievements: milestones,
            now: { self.date(2026, 6, 28) }
        )
        var existing = UserProfile.guest()
        existing.totalPoints = 250

        let (profile, unlocked) = svc.reconcileAchievements(for: existing)

        XCTAssertEqual(unlocked.map(\.id), ["points100", "points250"])
        XCTAssertEqual(Set(profile.unlockedAchievementIDs), ["points100", "points250"])
        XCTAssertEqual(profile.totalPoints, 250)
    }

    // MARK: Streak once per local day

    func testStreakIncrementsOncePerLocalDay_ViaLessons() {
        let svc = makeService(now: { self.date(2026, 6, 28) })
        let l1 = LessonFactory.lesson("l1", level: 1)
        let l2 = LessonFactory.lesson("l2", level: 2)

        let (p1, _) = svc.completeLesson(l1, for: .guest())
        XCTAssertEqual(p1.currentStreak, 1)
        let (p2, _) = svc.completeLesson(l2, for: p1)
        XCTAssertEqual(p2.currentStreak, 1, "two lessons same day keep the streak at 1")
    }

    func testStreakIncrementsOnConsecutiveDays() {
        var current = date(2026, 6, 28)
        let svc = makeService(now: { current })
        let session = PracticeSession(practiceID: "p", practiceTitle: "P", kind: .mantra,
                                      durationSeconds: 60, pointsEarned: 10)

        let (p1, _) = svc.recordSession(session, for: .guest())
        XCTAssertEqual(p1.currentStreak, 1)

        // Same day again: still 1.
        let (p1b, _) = svc.recordSession(session, for: p1)
        XCTAssertEqual(p1b.currentStreak, 1)

        // Next day: 2.
        current = date(2026, 6, 29)
        let (p2, _) = svc.recordSession(session, for: p1b)
        XCTAssertEqual(p2.currentStreak, 2)

        // Skip a day: resets to 1.
        current = date(2026, 7, 1)
        let (p3, _) = svc.recordSession(session, for: p2)
        XCTAssertEqual(p3.currentStreak, 1)
    }

    // MARK: Lesson-progress best score + resume

    func testFinalizeTracksBestScoreAndOnlyImproves() {
        let svc = makeService(now: { self.date(2026, 6, 28) })
        svc.finalizeLessonProgress(lessonID: "x", correctCount: 2, totalQuizCount: 3)
        XCTAssertEqual(svc.lessonProgress(for: "x")?.isCompleted, true)
        XCTAssertEqual(svc.lessonProgress(for: "x")?.bestCorrectCount, 2)

        svc.finalizeLessonProgress(lessonID: "x", correctCount: 1, totalQuizCount: 3)
        XCTAssertEqual(svc.lessonProgress(for: "x")?.bestCorrectCount, 2, "best score never lowers")

        svc.finalizeLessonProgress(lessonID: "x", correctCount: 3, totalQuizCount: 3)
        XCTAssertEqual(svc.lessonProgress(for: "x")?.bestCorrectCount, 3)
    }

    func testRecordStepMarksInProgressAndDedupesSteps() {
        let svc = makeService(now: { self.date(2026, 6, 28) })
        svc.recordStep(lessonID: "y", stepID: "s1", wasCorrect: nil, hintUsed: false, totalQuizCount: 2)
        XCTAssertEqual(svc.lessonProgress(for: "y")?.isInProgress, true)

        svc.recordStep(lessonID: "y", stepID: "s1", wasCorrect: true, hintUsed: true, totalQuizCount: 2)
        XCTAssertEqual(svc.lessonProgress(for: "y")?.completedStepIDs.count, 1, "same step not duplicated")
        XCTAssertEqual(svc.lessonProgress(for: "y")?.hintsUsed, 1)
    }
}
