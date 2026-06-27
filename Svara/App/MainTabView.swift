import SwiftUI

/// The five-tab spine of Svara: Today, Learn, Festivals, Stories, Profile.
struct MainTabView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var selection: Tab = .today
    @State private var showAchievement: Achievement?

    enum Tab: Hashable {
        case today, learn, festivals, stories, profile
    }

    var body: some View {
        TabView(selection: $selection) {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.and.horizon.fill") }
                .tag(Tab.today)

            LearnView()
                .tabItem { Label("Learn", systemImage: "graduationcap.fill") }
                .tag(Tab.learn)

            FestivalsView()
                .tabItem { Label("Festivals", systemImage: "sparkles") }
                .tag(Tab.festivals)

            StoriesView()
                .tabItem { Label("Stories", systemImage: "book.fill") }
                .tag(Tab.stories)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(Tab.profile)
        }
        .overlay(alignment: .top) {
            if let achievement = showAchievement {
                AchievementToast(achievement: achievement)
                    .padding(.horizontal, SvaraTheme.Spacing.lg)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .id(achievement.id)
            }
        }
        .onChange(of: env.pendingAchievements) { _, new in
            guard let first = new.first else { return }
            presentAchievement(first)
        }
        .animation(.spring(duration: 0.4), value: showAchievement)
    }

    private func presentAchievement(_ achievement: Achievement) {
        showAchievement = achievement
        Task {
            try? await Task.sleep(for: .seconds(2.6))
            showAchievement = nil
            env.clearPendingAchievements()
        }
    }
}

/// Celebratory toast shown when an achievement unlocks.
struct AchievementToast: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: SvaraTheme.Spacing.md) {
            Image(systemName: achievement.systemImage)
                .font(.title2)
                .foregroundStyle(SvaraTheme.Colors.points)
            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement unlocked!")
                    .font(.svaraCaption.weight(.bold))
                    .foregroundStyle(SvaraTheme.Colors.textOnDark.opacity(0.8))
                Text(achievement.title)
                    .font(.svaraHeadline)
                    .foregroundStyle(SvaraTheme.Colors.textOnDark)
            }
            Spacer(minLength: 0)
            if achievement.bonusPoints > 0 {
                Text("+\(achievement.bonusPoints)")
                    .font(.svaraHeadline)
                    .foregroundStyle(SvaraTheme.Colors.points)
            }
        }
        .padding(SvaraTheme.Spacing.lg)
        .background(SvaraTheme.Colors.surfaceInverse)
        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
    }
}

#Preview {
    MainTabView().environment(AppEnvironment.preview())
}
