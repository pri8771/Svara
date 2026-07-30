import SwiftUI

/// The Learn tab as a guided **Aaroh Path**: the next step is emotionally
/// obvious at the top, the path of chapters unfolds below, and brand-new
/// learners get a warm empty state inviting them to begin Day 1.
struct LearnView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var viewModel = LearnViewModel()
    @State private var activeLesson: Lesson?
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xl) {
                    GreetingHeader(eyebrow: LearnCopy.pathEyebrow, title: "Your Path")

                    if viewModel.isLoading {
                        ProgressView().frame(maxWidth: .infinity).padding(.vertical, SvaraTheme.Spacing.xxl)
                    } else if viewModel.pathLessons.isEmpty {
                        emptyState
                    } else {
                        nextStepHero
                        pathProgressBar
                        chaptersSection
                        if !viewModel.beyondLessons.isEmpty { beyondSection }
                    }
                }
                .padding(.horizontal, SvaraTheme.Spacing.screenMargin)
                .padding(.vertical, SvaraTheme.Spacing.lg)
            }
            .svaraScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
        .task {
            await viewModel.load(content: env.content)
            openDeepLinkedLesson(env.navigation.learnLessonID)
        }
        .onChange(of: env.navigation.learnLessonID) { _, id in openDeepLinkedLesson(id) }
        .fullScreenCover(item: $activeLesson) { LessonPlayerView(lesson: $0) }
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    /// Opens a lesson arrived at via a deep link (e.g. a shloka "lesson:" target),
    /// honouring premium gating.
    private func openDeepLinkedLesson(_ id: String?) {
        guard let id, let lesson = viewModel.lessons.first(where: { $0.id == id }) else { return }
        env.navigation.learnLessonID = nil
        if env.isLockedBehindPlus(lesson) {
            showPaywall = true
        } else {
            activeLesson = lesson
        }
    }

    // MARK: Recommendation

    private var recommendation: LessonRecommendation {
        viewModel.recommendation(
            completedIDs: env.completedLessonIDs,
            inProgressIDs: env.inProgressLessonIDs
        )
    }

    // MARK: Next-step hero (the emotionally obvious next action)

    @ViewBuilder
    private var nextStepHero: some View {
        let rec = recommendation
        if let lesson = rec.lesson {
            Button { open(lesson) } label: {
                SvaraCard(background: SvaraTheme.Colors.surfaceInverse) {
                    VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
                        Text(rec.eyebrow)
                            .font(.svaraCaption.weight(.bold))
                            .textCase(.uppercase)
                            .tracking(1.4)
                            .foregroundStyle(SvaraTheme.Colors.points)
                        Text(lesson.title)
                            .font(.svaraTitle)
                            .foregroundStyle(SvaraTheme.Colors.textOnDark)
                        Text(lesson.meaningOverview ?? lesson.subtitle)
                            .font(.svaraCallout)
                            .foregroundStyle(SvaraTheme.Colors.textOnDark.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: SvaraTheme.Spacing.sm) {
                            Image(systemName: heroIcon(rec.reason))
                            Text(heroCTA(rec.reason))
                            Spacer(minLength: 0)
                            if let day = lesson.pathDay { Text("Day \(day)").foregroundStyle(SvaraTheme.Colors.textOnDark.opacity(0.7)) }
                        }
                        .font(.svaraHeadline)
                        .foregroundStyle(SvaraTheme.Colors.points)
                        .padding(.top, SvaraTheme.Spacing.xs)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(rec.eyebrow). \(lesson.title). \(heroCTA(rec.reason)).")
        }
    }

    private func heroIcon(_ reason: LessonRecommendation.Reason) -> String {
        switch reason {
        case .continueInProgress: return "arrow.right.circle.fill"
        case .reviewCompleted: return "arrow.clockwise.circle.fill"
        default: return "play.circle.fill"
        }
    }

    private func heroCTA(_ reason: LessonRecommendation.Reason) -> String {
        switch reason {
        case .continueInProgress: return "Continue"
        case .reviewCompleted: return "Revisit"
        case .firstBeginner: return "Begin"
        default: return "Start"
        }
    }

    // MARK: Progress bar

    private var pathProgressBar: some View {
        let done = viewModel.pathCompletedCount(profile: env.profile)
        let total = viewModel.pathLessons.count
        return VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
            HStack {
                Text("\(done) of \(total) steps")
                    .font(.svaraHeadline)
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)
                Spacer()
                if done == total {
                    Label("Path complete", systemImage: "checkmark.seal.fill")
                        .font(.svaraCaption.weight(.semibold))
                        .foregroundStyle(SvaraTheme.Colors.success)
                }
            }
            ProgressView(value: total == 0 ? 0 : Double(done) / Double(total))
                .tint(SvaraTheme.Colors.primary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Path progress: \(done) of \(total) steps complete")
    }

    // MARK: Chapters

    private var chaptersSection: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
            SectionHeader(title: "The path", subtitle: "Three mantras, one step at a time")
            ForEach(viewModel.chapters) { chapter in
                NavigationLink {
                    MantraCourseView(
                        title: chapter.title,
                        subtitle: chapter.subtitle,
                        lessons: chapter.lessons,
                        allLessons: viewModel.lessons
                    )
                } label: {
                    ChapterCard(
                        chapter: chapter,
                        completedIDs: env.completedLessonIDs,
                        allLessons: viewModel.lessons
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: Beyond the path

    private var beyondSection: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
            SectionHeader(title: "Beyond the path", subtitle: "More to explore when you're ready")
            ForEach(viewModel.beyondLessons) { lesson in
                Button { open(lesson) } label: {
                    BeyondLessonRow(
                        lesson: lesson,
                        isCompleted: env.completedLessonIDs.contains(lesson.id),
                        isLocked: env.isLockedBehindPlus(lesson)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: Empty state

    private var emptyState: some View {
        VStack(spacing: SvaraTheme.Spacing.lg) {
            EmptyStateView(
                systemImage: "sparkles",
                title: LearnCopy.emptyStateTitle,
                message: LearnCopy.emptyStateMessage
            )
            if let first = viewModel.lessons.first {
                PrimaryButton(title: LearnCopy.emptyStateCTA, systemImage: "play.fill") { open(first) }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(LearnCopy.emptyStateTitle). \(LearnCopy.emptyStateMessage)")
    }

    // MARK: Actions

    private func open(_ lesson: Lesson) {
        if env.isLockedBehindPlus(lesson) {
            showPaywall = true
        } else {
            activeLesson = lesson
        }
    }
}

/// A chapter summary card: mantra title + how many steps are done.
private struct ChapterCard: View {
    let chapter: AarohChapter
    let completedIDs: Set<String>
    let allLessons: [Lesson]

    private var done: Int { chapter.lessons.filter { completedIDs.contains($0.id) }.count }
    private var total: Int { chapter.lessons.count }
    private var isCurrent: Bool {
        chapter.lessons.contains { AarohPath.state(for: $0, in: allLessons, completedIDs: completedIDs) == .current }
    }

    var body: some View {
        HStack(spacing: SvaraTheme.Spacing.lg) {
            ProgressRing(progress: total == 0 ? 0 : Double(done) / Double(total))
                .frame(width: 48, height: 48)
                .overlay(
                    Group {
                        if done == total {
                            Image(systemName: "checkmark").foregroundStyle(SvaraTheme.Colors.success)
                        } else {
                            Text("\(done)/\(total)").font(.svaraCaption.weight(.bold)).foregroundStyle(SvaraTheme.Colors.textPrimary)
                        }
                    }
                )
            VStack(alignment: .leading, spacing: 2) {
                if let day = chapter.lessons.first?.pathDay, let last = chapter.lessons.last?.pathDay {
                    Text(day == last ? "Day \(day)" : "Days \(day)–\(last)").svaraEyebrow()
                }
                Text(chapter.title)
                    .font(.svaraHeadline)
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)
                Text(done == total ? "Completed" : (isCurrent ? "In progress" : "Up next"))
                    .font(.svaraCaption)
                    .foregroundStyle(done == total ? SvaraTheme.Colors.success : SvaraTheme.Colors.textSecondary)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right").foregroundStyle(SvaraTheme.Colors.textSecondary)
        }
        .padding(SvaraTheme.Spacing.lg)
        .background(SvaraTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous)
                .strokeBorder(SvaraTheme.Colors.separator.opacity(0.7), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(chapter.title), \(done) of \(total) steps complete")
    }
}

/// A compact row for lessons beyond the guided path.
private struct BeyondLessonRow: View {
    let lesson: Lesson
    let isCompleted: Bool
    let isLocked: Bool

    var body: some View {
        HStack(spacing: SvaraTheme.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(isCompleted ? SvaraTheme.Colors.success : lesson.theme.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: isCompleted ? "checkmark" : lesson.theme.systemImage)
                    .foregroundStyle(isCompleted ? .white : lesson.theme.color)
            }
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(lesson.title)
                        .font(.svaraHeadline)
                        .foregroundStyle(SvaraTheme.Colors.textPrimary)
                    if isLocked { PremiumBadge() }
                }
                Text(lesson.subtitle)
                    .font(.svaraCallout)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
        }
        .padding(SvaraTheme.Spacing.lg)
        .background(SvaraTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous)
                .strokeBorder(SvaraTheme.Colors.separator.opacity(0.7), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(lesson.title)\(isCompleted ? ", completed" : "")\(isLocked ? ", requires Svara Plus" : "")")
    }
}

#Preview {
    LearnView().environment(AppEnvironment.preview())
}
