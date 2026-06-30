import SwiftUI

/// The gentle completion screen shown at the end of a lesson. It celebrates the
/// step, **unlocks one piece of meaning**, previews the next step on the path,
/// and gives a warm reason to return tomorrow.
///
/// No failure framing: even a low score is presented as familiarity gained, not
/// a test passed or failed (ProductGuardrails §5, §8.2).
struct LessonResultView: View {
    @Environment(AppEnvironment.self) private var env

    let lesson: Lesson
    let correctCount: Int
    let onDone: () -> Void

    @State private var nextLesson: Lesson?

    var body: some View {
        ScrollView {
            VStack(spacing: SvaraTheme.Spacing.xl) {
                celebration
                if lesson.insightTitle != nil { unlockCard }
                if let next = nextLesson { nextStepCard(next) } else { comeBackCard }
            }
            .padding(.top, SvaraTheme.Spacing.xl)
            .frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(title: "Done", action: onDone)
                .padding(.top, SvaraTheme.Spacing.sm)
        }
        .task {
            let all = await env.content.lessons()
            nextLesson = AarohPath.nextLesson(after: lesson, in: all)
        }
    }

    // MARK: Celebration

    private var celebration: some View {
        VStack(spacing: SvaraTheme.Spacing.md) {
            Image(systemName: "sun.and.horizon.fill")
                .font(.system(size: 72))
                .foregroundStyle(SvaraTheme.Colors.points)
                .accessibilityHidden(true)
            Text(LearnCopy.lessonCompleteTitle)
                .font(.svaraDisplay)
                .foregroundStyle(SvaraTheme.Colors.textPrimary)
            Text("+\(lesson.xp) Svara Points")
                .font(.svaraHeadline)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
            if lesson.quizCount > 0 {
                Text("You recognised \(correctCount) of \(lesson.quizCount) — familiarity grows each time.")
                    .font(.svaraCallout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
                    .padding(.horizontal, SvaraTheme.Spacing.lg)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(LearnCopy.lessonCompleteTitle). You earned \(lesson.xp) Svara Points.")
    }

    // MARK: Meaning unlock

    private var unlockCard: some View {
        SvaraCard(background: SvaraTheme.Colors.surfaceInverse) {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
                Label(LearnCopy.unlockedPrefix, systemImage: "lock.open.fill")
                    .font(.svaraCaption.weight(.bold))
                    .foregroundStyle(SvaraTheme.Colors.points)
                Text(lesson.insightTitle ?? "")
                    .font(.svaraTitle)
                    .foregroundStyle(SvaraTheme.Colors.textOnDark)
                if let body = lesson.insightBody {
                    Text(body)
                        .font(.svaraBody)
                        .foregroundStyle(SvaraTheme.Colors.textOnDark.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let tradition = lesson.traditionNote {
                    Text(tradition)
                        .font(.svaraCaption)
                        .italic()
                        .foregroundStyle(SvaraTheme.Colors.textOnDark.opacity(0.7))
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(LearnCopy.unlockedLine(lesson.insightTitle ?? ""))
    }

    // MARK: Next step

    private func nextStepCard(_ next: Lesson) -> some View {
        SvaraCard {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
                Text("UNLOCKED — NEXT STEP").svaraEyebrow()
                HStack(spacing: SvaraTheme.Spacing.md) {
                    ZStack {
                        Circle().fill(next.theme.color.opacity(0.15)).frame(width: 44, height: 44)
                        Image(systemName: next.theme.systemImage).foregroundStyle(next.theme.color)
                    }
                    .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(next.title)
                            .font(.svaraHeadline)
                            .foregroundStyle(SvaraTheme.Colors.textPrimary)
                        Text(next.meaningOverview ?? next.subtitle)
                            .font(.svaraCallout)
                            .foregroundStyle(SvaraTheme.Colors.textSecondary)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 0)
                }
                Text(LearnCopy.comeBackTomorrow)
                    .font(.svaraCallout)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Next step unlocked: \(next.title). \(LearnCopy.comeBackTomorrow)")
    }

    private var comeBackCard: some View {
        SvaraCard {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
                Text(LearnCopy.allCaughtUpTitle)
                    .font(.svaraHeadline)
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)
                Text(LearnCopy.allCaughtUpMessage)
                    .font(.svaraCallout)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
            }
        }
    }
}

#Preview {
    LessonResultView(lesson: SeedContent.lessons[3], correctCount: 2) {}
        .environment(AppEnvironment.preview())
}
