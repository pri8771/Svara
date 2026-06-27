import SwiftUI

/// A titled section header with an optional trailing accessory.
struct SectionHeader<Accessory: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder var accessory: () -> Accessory

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.svaraTitle)
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.svaraCallout)
                        .foregroundStyle(SvaraTheme.Colors.textSecondary)
                }
            }
            Spacer(minLength: 0)
            accessory()
        }
    }
}

extension SectionHeader where Accessory == EmptyView {
    init(title: String, subtitle: String? = nil) {
        self.init(title: title, subtitle: subtitle, accessory: { EmptyView() })
    }
}

/// A small rounded pill showing an icon + value, used for streaks and points.
struct StatPill: View {
    let systemImage: String
    let value: String
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
            Text(value)
                .font(.svaraHeadline)
                .foregroundStyle(SvaraTheme.Colors.textPrimary)
        }
        .padding(.horizontal, SvaraTheme.Spacing.md)
        .padding(.vertical, SvaraTheme.Spacing.sm)
        .background(SvaraTheme.Colors.surface)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(tint.opacity(0.25), lineWidth: 1))
    }
}

/// A category / theme chip.
struct ThemeChip: View {
    let theme: SpiritualTheme
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: theme.systemImage)
            Text(theme.label)
        }
        .font(.svaraCaption.weight(.semibold))
        .padding(.horizontal, SvaraTheme.Spacing.md)
        .padding(.vertical, SvaraTheme.Spacing.sm)
        .foregroundStyle(isSelected ? Color.white : theme.color)
        .background(isSelected ? theme.color : theme.color.opacity(0.12))
        .clipShape(Capsule())
    }
}

/// A circular progress ring used for streaks / lesson progress.
struct ProgressRing: View {
    let progress: Double // 0...1
    var lineWidth: CGFloat = 8
    var tint: Color = SvaraTheme.Colors.primary

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.18), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)
        }
    }
}

/// A friendly empty-state placeholder.
struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: SvaraTheme.Spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundStyle(SvaraTheme.Colors.primary)
            Text(title)
                .font(.svaraHeadline)
                .foregroundStyle(SvaraTheme.Colors.textPrimary)
            Text(message)
                .font(.svaraCallout)
                .multilineTextAlignment(.center)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SvaraTheme.Spacing.xxl)
    }
}

/// A reusable lock badge for premium content.
struct PremiumBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "lock.fill")
            Text("Plus")
        }
        .font(.svaraCaption.weight(.bold))
        .foregroundStyle(SvaraTheme.Colors.textOnPrimary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(SvaraTheme.Colors.points)
        .clipShape(Capsule())
    }
}
