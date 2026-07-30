import SwiftUI

/// Svara's primary spine. Tabs are driven by `FeatureFlags.primaryTabs` so the
/// focused beta (Today + Learn) and the full product share one code path; Today
/// and Learn are always present and first (see `FeatureFlags`).
struct MainTabView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var showAchievement: Achievement?

    var body: some View {
        @Bindable var nav = env.navigation
        TabView(selection: $nav.selection) {
            ForEach(env.featureFlags.primaryTabs) { tab in
                view(for: tab)
                    .tabItem { Label(tab.title, systemImage: tab.systemImage) }
                    .tag(tab)
            }
        }
        .onChange(of: env.navigation.selection) { _, new in
            // A deep link could target a tab that's staged out of the current
            // scope; fall back to Today so selection always points at a real tab.
            if !env.featureFlags.primaryTabs.contains(new) {
                env.navigation.selection = .today
            }
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
            guard showAchievement == nil, let first = new.first else { return }
            presentAchievement(first)
        }
        .animation(.spring(duration: 0.4), value: showAchievement)
    }

    @ViewBuilder
    private func view(for tab: MainTab) -> some View {
        switch tab {
        case .today: TodayView()
        case .learn: LearnView()
        case .festivals: FestivalsView()
        case .stories: StoriesHomeView()
        case .profile: ProfileView()
        }
    }

    private func presentAchievement(_ achievement: Achievement) {
        showAchievement = achievement
        Task {
            try? await Task.sleep(for: .seconds(2.6))
            showAchievement = nil
            env.clearPendingAchievement(achievement)
            if let next = env.pendingAchievements.first {
                presentAchievement(next)
            }
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
