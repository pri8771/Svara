import SwiftUI

/// A Duolingo-style learning path of mantra/sloka lessons.
struct LearnView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var viewModel = LearnViewModel()
    @State private var activeLesson: Lesson?
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xl) {
                    GreetingHeader(eyebrow: "LEARN", title: "Lessons")
                    progressCard

                    LazyVStack(spacing: SvaraTheme.Spacing.md) {
                        ForEach(Array(viewModel.lessons.enumerated()), id: \.element.id) { index, lesson in
                            LessonRow(
                                lesson: lesson,
                                index: index,
                                isCompleted: env.isLessonCompleted(lesson),
                                isLocked: lesson.isPremium && !env.isPremium
                            ) {
                                if lesson.isPremium && !env.isPremium {
                                    showPaywall = true
                                } else {
                                    activeLesson = lesson
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, SvaraTheme.Spacing.screenMargin)
                .padding(.vertical, SvaraTheme.Spacing.lg)
            }
            .svaraScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
        .task { await viewModel.load(content: env.content) }
        .fullScreenCover(item: $activeLesson) { lesson in
            LessonPlayerView(lesson: lesson)
        }
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private var progressCard: some View {
        SvaraCard {
            HStack(spacing: SvaraTheme.Spacing.lg) {
                ProgressRing(progress: viewModel.progress(profile: env.profile))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "graduationcap.fill")
                            .foregroundStyle(SvaraTheme.Colors.primary)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.completedCount(profile: env.profile)) of \(viewModel.lessons.count) lessons")
                        .font(.svaraHeadline)
                        .foregroundStyle(SvaraTheme.Colors.textPrimary)
                    Text("Keep going — each lesson is just a few minutes.")
                        .font(.svaraCallout)
                        .foregroundStyle(SvaraTheme.Colors.textSecondary)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

private struct LessonRow: View {
    let lesson: Lesson
    let index: Int
    let isCompleted: Bool
    let isLocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SvaraTheme.Spacing.lg) {
                node
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Lesson \(lesson.level)")
                            .svaraEyebrow()
                        if isLocked { PremiumBadge() }
                    }
                    Text(lesson.title)
                        .font(.svaraHeadline)
                        .foregroundStyle(SvaraTheme.Colors.textPrimary)
                    Text(lesson.subtitle)
                        .font(.svaraCallout)
                        .foregroundStyle(SvaraTheme.Colors.textSecondary)
                        .lineLimit(1)
                    HStack(spacing: SvaraTheme.Spacing.md) {
                        Label("\(lesson.stepCount) steps", systemImage: "list.bullet")
                        Label("+\(lesson.xp) XP", systemImage: "sparkles")
                    }
                    .font(.svaraCaption)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
                }
                Spacer(minLength: 0)
                Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
            }
        }
        .buttonStyle(.plain)
        .padding(SvaraTheme.Spacing.lg)
        .background(SvaraTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous)
                .strokeBorder(SvaraTheme.Colors.separator.opacity(0.7), lineWidth: 1)
        )
    }

    private var node: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? SvaraTheme.Colors.success : lesson.theme.color.opacity(0.15))
                .frame(width: 52, height: 52)
            Image(systemName: isCompleted ? "checkmark" : lesson.theme.systemImage)
                .font(.headline)
                .foregroundStyle(isCompleted ? .white : lesson.theme.color)
        }
    }
}

#Preview {
    LearnView().environment(AppEnvironment.preview())
}
