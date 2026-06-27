import SwiftUI

/// Full reading view for a mantra: Sanskrit, transliteration, translation and
/// meaning. Reused from Today, Learn and Stories.
struct MantraDetailView: View {
    let mantra: Mantra

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xl) {
                header

                block(title: "Sanskrit", body: mantra.sanskrit, font: .svaraSanskrit, color: SvaraTheme.Colors.textPrimary)
                block(title: "Transliteration", body: mantra.transliteration, font: .svaraBody.italic(), color: SvaraTheme.Colors.accent)
                block(title: "Translation", body: mantra.translation, font: .svaraBody, color: SvaraTheme.Colors.textPrimary)

                SvaraCard {
                    VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
                        Text("Meaning & when to use it").svaraEyebrow()
                        Text(mantra.meaning)
                            .font(.svaraBody)
                            .foregroundStyle(SvaraTheme.Colors.textPrimary)
                    }
                }

                HStack(spacing: SvaraTheme.Spacing.md) {
                    StatPill(systemImage: "repeat", value: "\(mantra.repetitions)x", tint: SvaraTheme.Colors.accent)
                    StatPill(systemImage: "clock", value: "\(mantra.durationMinutes) min", tint: SvaraTheme.Colors.primary)
                }
            }
            .padding(.horizontal, SvaraTheme.Spacing.screenMargin)
            .padding(.vertical, SvaraTheme.Spacing.lg)
        }
        .svaraScreenBackground()
        .navigationTitle(mantra.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
            ThemeChip(theme: mantra.theme)
            Text(mantra.title)
                .font(.svaraDisplay)
                .foregroundStyle(SvaraTheme.Colors.textPrimary)
            Label(mantra.deity, systemImage: "leaf.fill")
                .font(.svaraCallout)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
        }
    }

    private func block(title: String, body: String, font: Font, color: Color) -> some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xs) {
            Text(title).svaraEyebrow()
            Text(body)
                .font(font)
                .foregroundStyle(color)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        MantraDetailView(mantra: SeedContent.mantras[0])
    }
}
