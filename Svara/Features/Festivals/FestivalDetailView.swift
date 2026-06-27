import SwiftUI

struct FestivalDetailView: View {
    @Environment(AppEnvironment.self) private var env
    let festival: Festival

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xl) {
                hero

                section(title: "Why it matters", body: festival.significance)
                section(title: "The story", body: festival.story)

                VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
                    Text("Mark the moment").svaraEyebrow()
                    ForEach(Array(festival.activities.enumerated()), id: \.offset) { _, activity in
                        HStack(alignment: .top, spacing: SvaraTheme.Spacing.md) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundStyle(festival.theme.color)
                                .padding(.top, 7)
                            Text(activity)
                                .font(.svaraBody)
                                .foregroundStyle(SvaraTheme.Colors.textPrimary)
                        }
                    }
                }

                observeButton
            }
            .padding(.horizontal, SvaraTheme.Spacing.screenMargin)
            .padding(.vertical, SvaraTheme.Spacing.lg)
        }
        .svaraScreenBackground()
        .navigationTitle(festival.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
            HStack {
                Image(systemName: festival.systemImage)
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                Spacer()
                if let deity = festival.deity {
                    Label(deity, systemImage: "leaf.fill")
                        .font(.svaraCallout)
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            Text(festival.name)
                .font(.svaraDisplay)
                .foregroundStyle(.white)
            Text(festival.tagline)
                .font(.svaraBody)
                .foregroundStyle(.white.opacity(0.9))
            Text(dateLabel)
                .font(.svaraCallout.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, SvaraTheme.Spacing.md)
                .padding(.vertical, SvaraTheme.Spacing.sm)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
        }
        .padding(SvaraTheme.Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SvaraTheme.Gradients.dusk)
        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous))
    }

    private var observeButton: some View {
        Group {
            if env.isFestivalObserved(festival) {
                Label("You observed this festival", systemImage: "checkmark.seal.fill")
                    .font(.svaraHeadline)
                    .foregroundStyle(SvaraTheme.Colors.success)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SvaraTheme.Spacing.md)
            } else {
                PrimaryButton(title: "Mark as observed", systemImage: "checkmark") {
                    env.observeFestival(festival)
                }
            }
        }
        .padding(.top, SvaraTheme.Spacing.md)
    }

    private func section(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
            Text(title).svaraEyebrow()
            Text(body)
                .font(.svaraBody)
                .foregroundStyle(SvaraTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: festival.date)
    }
}

#Preview {
    NavigationStack {
        FestivalDetailView(festival: SeedContent.festivals[0])
            .environment(AppEnvironment.preview())
    }
}
