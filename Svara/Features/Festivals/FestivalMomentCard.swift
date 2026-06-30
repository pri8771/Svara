import SwiftUI

/// A compact, tappable festival "moment" card: name, countdown, a line of
/// context, and an Explore affordance. Used in the "Coming soon" rail and the
/// "This season" section. Reusable and preview-friendly.
struct FestivalMomentCard: View {
    let festival: Festival
    let daysUntil: Int
    /// Fixed width when used in a horizontal rail; `nil` = flexible width.
    var fixedWidth: CGFloat? = 260

    var body: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
            HStack(spacing: SvaraTheme.Spacing.sm) {
                ZStack {
                    Circle().fill(festival.theme.color.opacity(0.16)).frame(width: 40, height: 40)
                    Image(systemName: festival.systemImage)
                        .foregroundStyle(festival.theme.color)
                }
                .accessibilityHidden(true)
                Spacer(minLength: 0)
                countdownBadge
            }

            Text(festival.name)
                .font(.svaraHeadline)
                .foregroundStyle(SvaraTheme.Colors.textPrimary)
                .lineLimit(2)

            Text(festival.shortContext)
                .font(.svaraCallout)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            HStack(spacing: 6) {
                Text("Explore")
                Image(systemName: "arrow.right")
            }
            .font(.svaraCaption.weight(.bold))
            .foregroundStyle(festival.theme.color)
        }
        .padding(SvaraTheme.Spacing.lg)
        .frame(width: fixedWidth, alignment: .leading)
        .frame(minHeight: 150, alignment: .topLeading)
        .background(SvaraTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous)
                .strokeBorder(SvaraTheme.Colors.separator.opacity(0.7), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(festival.name), \(FestivalCountdown.label(daysUntil: daysUntil)). \(festival.shortContext)")
        .accessibilityHint("Explore this festival")
    }

    @ViewBuilder
    private var countdownBadge: some View {
        if FestivalCountdown.isToday(daysUntil: daysUntil) {
            Text("Today")
                .font(.svaraCaption.weight(.bold))
                .foregroundStyle(SvaraTheme.Colors.textOnPrimary)
                .padding(.horizontal, SvaraTheme.Spacing.sm)
                .padding(.vertical, 4)
                .background(SvaraTheme.Colors.primary)
                .clipShape(Capsule())
        } else {
            Text(FestivalCountdown.label(daysUntil: daysUntil))
                .font(.svaraCaption.weight(.semibold))
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
        }
    }
}

#Preview {
    HStack {
        FestivalMomentCard(festival: SeedContent.festivals[0], daysUntil: 0)
        FestivalMomentCard(festival: SeedContent.festivals[1], daysUntil: 12)
    }
    .padding()
    .background(SvaraTheme.Colors.background)
}
