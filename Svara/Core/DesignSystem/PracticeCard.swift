import SwiftUI

/// A rich, tappable card representing a daily practice on the Today screen.
struct PracticeCard: View {
    let practice: DailyPractice
    var isCompleted: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SvaraTheme.Spacing.lg) {
                iconBadge
                VStack(alignment: .leading, spacing: 4) {
                    Text(practice.timeOfDay.label.uppercased())
                        .font(.svaraCaption.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(SvaraTheme.Colors.textOnDark.opacity(0.75))
                    Text(practice.title)
                        .font(.svaraHeadline)
                        .foregroundStyle(SvaraTheme.Colors.textOnDark)
                    Text(practice.subtitle)
                        .font(.svaraCallout)
                        .foregroundStyle(SvaraTheme.Colors.textOnDark.opacity(0.85))
                        .lineLimit(2)
                    HStack(spacing: SvaraTheme.Spacing.md) {
                        Label("\(practice.durationMinutes) min", systemImage: "clock")
                        Label("+\(practice.points)", systemImage: "sparkles")
                    }
                    .font(.svaraCaption)
                    .foregroundStyle(SvaraTheme.Colors.textOnDark.opacity(0.85))
                    .padding(.top, 2)
                }
                Spacer(minLength: 0)
                completionIcon
            }
            .padding(SvaraTheme.Spacing.lg)
            .background(SvaraTheme.Gradients.forTimeOfDay(practice.timeOfDay))
            .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous))
            .shadow(color: SvaraTheme.Palette.indigo.opacity(0.25), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    private var iconBadge: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 52, height: 52)
            Image(systemName: practice.systemImage)
                .font(.title2)
                .foregroundStyle(.white)
        }
    }

    private var completionIcon: some View {
        Image(systemName: isCompleted ? "checkmark.circle.fill" : "chevron.right.circle.fill")
            .font(.title2)
            .foregroundStyle(isCompleted ? SvaraTheme.Colors.success : Color.white.opacity(0.9))
    }
}

#Preview {
    VStack(spacing: 16) {
        PracticeCard(
            practice: DailyPractice(
                id: "p1",
                title: "Morning Mantra",
                subtitle: "Begin the day with the Gayatri Mantra",
                kind: .mantra,
                timeOfDay: .morning,
                guidance: []
            )
        ) {}
        PracticeCard(
            practice: DailyPractice(
                id: "p2",
                title: "Evening Prayer",
                subtitle: "Wind down with gratitude",
                kind: .prayer,
                timeOfDay: .evening
            ),
            isCompleted: true
        ) {}
    }
    .padding()
    .background(SvaraTheme.Colors.background)
}
