import SwiftUI

/// The home of Svara: a warm daily snapshot — streak, today's practices and a
/// mantra of the day.
struct TodayView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var viewModel = TodayViewModel()
    @State private var activePractice: DailyPractice?
    @State private var activeLesson: Lesson?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xl) {
                    GreetingHeader(
                        eyebrow: todayString,
                        title: "\(viewModel.greeting),\n\(env.profile.displayName)"
                    )
                    streakBanner

                    continueAarohCard

                    SectionHeader(title: "Today's practices", subtitle: "A few mindful minutes")
                    practiceList

                    if let mantra = viewModel.mantraOfDay {
                        SectionHeader(title: "Mantra of the day")
                        NavigationLink {
                            MantraDetailView(mantra: mantra)
                        } label: {
                            MantraOfDayCard(mantra: mantra)
                        }
                        .buttonStyle(.plain)
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
        .fullScreenCover(item: $activePractice) { practice in
            PracticePlayerView(practice: practice, mantra: viewModel.mantra(id: practice.mantraID))
        }
        .fullScreenCover(item: $activeLesson) { LessonPlayerView(lesson: $0) }
    }

    /// Surfaces the learner's next Aaroh step right on the home screen so it's
    /// obvious within a few seconds of opening the app.
    @ViewBuilder
    private var continueAarohCard: some View {
        let rec = viewModel.aarohRecommendation(
            completedIDs: env.completedLessonIDs,
            inProgressIDs: env.inProgressLessonIDs
        )
        if let lesson = rec.lesson {
            Button { activeLesson = lesson } label: {
                SvaraCard {
                    HStack(spacing: SvaraTheme.Spacing.lg) {
                        ZStack {
                            Circle().fill(lesson.theme.color.opacity(0.15)).frame(width: 48, height: 48)
                            Image(systemName: aarohIcon(rec.reason)).foregroundStyle(lesson.theme.color)
                        }
                        .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(rec.eyebrow).svaraEyebrow()
                            Text(lesson.title)
                                .font(.svaraHeadline)
                                .foregroundStyle(SvaraTheme.Colors.textPrimary)
                            Text(aarohSubtitle(rec.reason))
                                .font(.svaraCallout)
                                .foregroundStyle(SvaraTheme.Colors.textSecondary)
                                .lineLimit(1)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right").foregroundStyle(SvaraTheme.Colors.textSecondary)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(rec.eyebrow). \(lesson.title). \(aarohSubtitle(rec.reason)).")
        }
    }

    private func aarohIcon(_ reason: LessonRecommendation.Reason) -> String {
        switch reason {
        case .continueInProgress: return "arrow.right.circle.fill"
        case .reviewCompleted: return "arrow.clockwise"
        default: return "play.fill"
        }
    }

    private func aarohSubtitle(_ reason: LessonRecommendation.Reason) -> String {
        switch reason {
        case .continueInProgress: return "Pick up where you left off — about a minute."
        case .reviewCompleted: return "You've finished the path — revisit a step."
        case .firstBeginner: return "Start your path — about a minute."
        default: return "Your next step — about a minute."
        }
    }

    private var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date()).uppercased()
    }

    private var streakBanner: some View {
        SvaraCard(background: SvaraTheme.Colors.surfaceInverse) {
            HStack(spacing: SvaraTheme.Spacing.lg) {
                VStack(alignment: .leading, spacing: 4) {
                    Label("\(env.profile.currentStreak)-day streak", systemImage: "flame.fill")
                        .font(.svaraHeadline)
                        .foregroundStyle(SvaraTheme.Colors.textOnDark)
                    Text(env.profile.currentStreak == 0
                         ? "Begin today and start your streak."
                         : "Keep the flame alive — practice today.")
                        .font(.svaraCallout)
                        .foregroundStyle(SvaraTheme.Colors.textOnDark.opacity(0.8))
                }
                Spacer(minLength: 0)
                VStack(spacing: 2) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(SvaraTheme.Colors.points)
                    Text("\(env.profile.totalPoints)")
                        .font(.svaraTitle)
                        .foregroundStyle(SvaraTheme.Colors.textOnDark)
                    Text("points")
                        .font(.svaraCaption)
                        .foregroundStyle(SvaraTheme.Colors.textOnDark.opacity(0.7))
                }
            }
        }
    }

    private var practiceList: some View {
        VStack(spacing: SvaraTheme.Spacing.md) {
            if viewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity).padding()
            } else {
                ForEach(viewModel.orderedPractices()) { practice in
                    PracticeCard(
                        practice: practice,
                        isCompleted: env.hasCompletedPractice(practice)
                    ) {
                        activePractice = practice
                    }
                }
            }
        }
    }
}

/// Compact card for the mantra of the day.
struct MantraOfDayCard: View {
    let mantra: Mantra

    var body: some View {
        SvaraCard {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
                HStack {
                    ThemeChip(theme: mantra.theme)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(SvaraTheme.Colors.textSecondary)
                }
                Text(mantra.title)
                    .font(.svaraTitle)
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)
                Text(mantra.sanskrit)
                    .font(.svaraSanskrit)
                    .foregroundStyle(SvaraTheme.Colors.accent)
                    .lineLimit(2)
                Text(mantra.translation)
                    .font(.svaraCallout)
                    .italic()
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
            }
        }
    }
}

#Preview {
    TodayView().environment(AppEnvironment.preview())
}
