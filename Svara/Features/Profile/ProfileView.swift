import SwiftUI

/// The user's home base: streak, Svara Points, achievements and a way into
/// settings and the upgrade.
struct ProfileView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var viewModel = ProfileViewModel()
    @State private var showPaywall = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xl) {
                    profileHeader
                    statsRow
                    if !env.isPremium { upgradeCard }
                    achievementsSection
                }
                .padding(.horizontal, SvaraTheme.Spacing.screenMargin)
                .padding(.vertical, SvaraTheme.Spacing.lg)
            }
            .svaraScreenBackground()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(SvaraTheme.Colors.accent)
                    }
                }
            }
        }
        .task { await viewModel.load(content: env.content) }
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private var profileHeader: some View {
        VStack(spacing: SvaraTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(SvaraTheme.Gradients.dawn)
                    .frame(width: 92, height: 92)
                Image(systemName: env.profile.avatarSystemImage)
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
            }
            VStack(spacing: 2) {
                HStack(spacing: 6) {
                    Text(env.profile.displayName)
                        .font(.svaraTitle)
                        .foregroundStyle(SvaraTheme.Colors.textPrimary)
                    if env.isPremium {
                        Image(systemName: "star.circle.fill")
                            .foregroundStyle(SvaraTheme.Colors.points)
                    }
                }
                Text(memberSince)
                    .font(.svaraCallout)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var statsRow: some View {
        HStack(spacing: SvaraTheme.Spacing.md) {
            StatTile(value: "\(env.profile.currentStreak)", label: "Day streak", systemImage: "flame.fill", tint: SvaraTheme.Colors.streakFlame)
            StatTile(value: "\(env.profile.totalPoints)", label: "Svara Points", systemImage: "sparkles", tint: SvaraTheme.Colors.points)
            StatTile(value: "\(env.profile.longestStreak)", label: "Best streak", systemImage: "trophy.fill", tint: SvaraTheme.Colors.accent)
        }
    }

    private var upgradeCard: some View {
        Button { showPaywall = true } label: {
            SvaraCard(background: SvaraTheme.Colors.surfaceInverse) {
                HStack(spacing: SvaraTheme.Spacing.lg) {
                    Image(systemName: "star.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(SvaraTheme.Colors.points)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Svara Plus")
                            .font(.svaraHeadline)
                            .foregroundStyle(SvaraTheme.Colors.textOnDark)
                        Text("Unlock every lesson, story and festival.")
                            .font(.svaraCallout)
                            .foregroundStyle(SvaraTheme.Colors.textOnDark.opacity(0.8))
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(SvaraTheme.Colors.textOnDark.opacity(0.7))
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
            SectionHeader(
                title: "Achievements",
                subtitle: "\(viewModel.unlockedCount(profile: env.profile)) of \(viewModel.achievements.count) unlocked"
            )
            LazyVGrid(columns: columns, spacing: SvaraTheme.Spacing.md) {
                ForEach(viewModel.achievements) { achievement in
                    AchievementBadge(
                        achievement: achievement,
                        isUnlocked: env.isAchievementUnlocked(achievement),
                        progress: env.progress.progress(for: achievement, profile: env.profile)
                    )
                }
            }
        }
    }

    private var memberSince: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return "Practising since \(formatter.string(from: env.profile.joinedDate))"
    }
}

private struct StatTile: View {
    let value: String
    let label: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(tint)
            Text(value)
                .font(.svaraTitle)
                .foregroundStyle(SvaraTheme.Colors.textPrimary)
            Text(label)
                .font(.svaraCaption)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SvaraTheme.Spacing.lg)
        .background(SvaraTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous)
                .strokeBorder(SvaraTheme.Colors.separator.opacity(0.7), lineWidth: 1)
        )
    }
}

private struct AchievementBadge: View {
    let achievement: Achievement
    let isUnlocked: Bool
    let progress: Double

    var body: some View {
        VStack(spacing: SvaraTheme.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? SvaraTheme.Colors.points.opacity(0.2) : SvaraTheme.Colors.separator.opacity(0.4))
                    .frame(width: 60, height: 60)
                if !isUnlocked {
                    ProgressRing(progress: progress, lineWidth: 4, tint: SvaraTheme.Colors.primary)
                        .frame(width: 60, height: 60)
                }
                Image(systemName: achievement.systemImage)
                    .font(.title3)
                    .foregroundStyle(isUnlocked ? SvaraTheme.Colors.points : SvaraTheme.Colors.textSecondary)
            }
            Text(achievement.title)
                .font(.svaraCaption.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(isUnlocked ? SvaraTheme.Colors.textPrimary : SvaraTheme.Colors.textSecondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .opacity(isUnlocked ? 1 : 0.85)
    }
}

#Preview {
    ProfileView().environment(AppEnvironment.preview())
}
