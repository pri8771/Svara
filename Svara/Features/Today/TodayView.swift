import SwiftUI

/// The home of Svara: a warm daily snapshot — streak, today's practices and a
/// mantra of the day.
struct TodayView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var viewModel = TodayViewModel()
    @State private var activePractice: DailyPractice?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xl) {
                    GreetingHeader(
                        eyebrow: todayString,
                        title: "\(viewModel.greeting),\n\(env.profile.displayName)"
                    )
                    streakBanner

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
