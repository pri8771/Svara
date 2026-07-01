import SwiftUI

/// A festival "moment" page: an illustrated hero, date + region tags, why it
/// matters, the story, its symbols, a tiny 2–5 minute activity, a family
/// conversation prompt, and a related mantra/practice if available.
///
/// No ritual simulation, no booking, no public feed — just understanding plus
/// one tiny, optional thing to do, "in your own way".
struct FestivalDetailView: View {
    @Environment(AppEnvironment.self) private var env
    let festival: Festival

    @State private var relatedMantra: Mantra?
    @State private var relatedPractice: DailyPractice?
    @State private var practiceMantra: Mantra?
    @State private var activeCover: ActiveCover?

    /// A single full-screen cover, enum-driven (multiple `.fullScreenCover`
    /// modifiers on one view can conflict).
    private enum ActiveCover: Identifiable {
        case activity
        case practice(DailyPractice)
        var id: String {
            switch self {
            case .activity: return "activity"
            case .practice(let p): return "practice.\(p.id)"
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xl) {
                hero
                tagRow

                section(title: "Why it matters", body: festival.whyItMattersText)
                section(title: "The story", body: festival.story)

                if !festival.symbols.isEmpty { symbolsSection }
                if festival.tinyActivity != nil { activityCard }
                if let prompt = festival.familyPrompt { familyPromptCard(prompt) }
                relatedSection
                moreWaysSection
                if let note = festival.traditionNote { traditionNote(note) }
                saveShareRow
            }
            .padding(.horizontal, SvaraTheme.Spacing.screenMargin)
            .padding(.vertical, SvaraTheme.Spacing.lg)
        }
        .svaraScreenBackground()
        .navigationTitle(festival.name)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $activeCover) { cover in
            switch cover {
            case .activity:
                FestivalActivityView(festival: festival)
            case .practice(let practice):
                PracticePlayerView(practice: practice, mantra: practiceMantra)
            }
        }
        .task { await loadRelated() }
    }

    // MARK: Hero (illustration placeholder)

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            // Illustration placeholder: themed gradient + large glyph.
            RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous)
                .fill(SvaraTheme.Gradients.dusk)
                .frame(height: 180)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: festival.systemImage)
                        .font(.system(size: 88))
                        .foregroundStyle(.white.opacity(0.18))
                        .padding(SvaraTheme.Spacing.md)
                        .accessibilityHidden(true)
                }
            VStack(alignment: .leading, spacing: 6) {
                if let deity = festival.deity {
                    Label(deity, systemImage: "leaf.fill")
                        .font(.svaraCallout)
                        .foregroundStyle(.white.opacity(0.9))
                }
                Text(festival.name)
                    .font(.svaraDisplay)
                    .foregroundStyle(.white)
                Text(festival.tagline)
                    .font(.svaraBody)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(SvaraTheme.Spacing.xl)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(festival.name). \(festival.tagline)")
    }

    // MARK: Date + region tags

    private var tagRow: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
            HStack(spacing: SvaraTheme.Spacing.sm) {
                StatPill(systemImage: "calendar", value: dateLabel, tint: SvaraTheme.Colors.accent)
                StatPill(systemImage: "clock", value: FestivalCountdown.label(daysUntil: festival.daysUntil()), tint: SvaraTheme.Colors.primary)
            }
            if festival.isDateApproximate {
                Text("Dates can vary by region and tradition.")
                    .font(.svaraCaption)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
            }
            if !regionLabels.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(regionLabels, id: \.self) { label in
                            Text(label)
                                .font(.svaraCaption.weight(.semibold))
                                .foregroundStyle(SvaraTheme.Colors.accent)
                                .padding(.horizontal, SvaraTheme.Spacing.sm)
                                .padding(.vertical, 4)
                                .background(SvaraTheme.Colors.accent.opacity(0.10))
                                .clipShape(Capsule())
                        }
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Regions: \(regionLabels.joined(separator: ", "))")
            }
        }
    }

    private var regionLabels: [String] {
        festival.regionTags.compactMap { FestivalRegion(rawValue: $0)?.label }
    }

    // MARK: Symbols

    private var symbolsSection: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
            Text("Symbols").svaraEyebrow()
            ForEach(festival.symbols) { symbol in
                HStack(alignment: .top, spacing: SvaraTheme.Spacing.md) {
                    Image(systemName: "circle.hexagongrid.fill")
                        .foregroundStyle(festival.theme.color)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(symbol.name)
                            .font(.svaraHeadline)
                            .foregroundStyle(SvaraTheme.Colors.textPrimary)
                        Text(symbol.meaning)
                            .font(.svaraCallout)
                            .foregroundStyle(SvaraTheme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    // MARK: Tiny activity

    @ViewBuilder
    private var activityCard: some View {
        if let activity = festival.tinyActivity {
            let done = env.hasCompletedFestivalActivity(festival)
            SvaraCard(background: SvaraTheme.Colors.surfaceInverse) {
                VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
                    Text("A tiny way to connect today").svaraEyebrow()
                    Text(activity.title)
                        .font(.svaraTitle)
                        .foregroundStyle(SvaraTheme.Colors.textOnDark)
                    Label("\(activity.durationMinutes) min · try it in your own way", systemImage: "leaf.fill")
                        .font(.svaraCallout)
                        .foregroundStyle(SvaraTheme.Colors.textOnDark.opacity(0.85))
                    if done {
                        Label("You marked this moment", systemImage: "checkmark.seal.fill")
                            .font(.svaraHeadline)
                            .foregroundStyle(SvaraTheme.Colors.points)
                            .padding(.top, SvaraTheme.Spacing.xs)
                    } else {
                        Button { activeCover = .activity } label: {
                            HStack {
                                Text("Begin")
                                Image(systemName: "arrow.right")
                                Spacer()
                                Text("+\(activity.points)")
                            }
                            .font(.svaraHeadline)
                            .foregroundStyle(SvaraTheme.Colors.textOnPrimary)
                            .padding(.vertical, 14)
                            .padding(.horizontal, SvaraTheme.Spacing.lg)
                            .frame(maxWidth: .infinity)
                            .background(SvaraTheme.Gradients.saffron)
                            .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, SvaraTheme.Spacing.xs)
                        .accessibilityLabel("Begin the activity, earns \(activity.points) Svara Points once")
                    }
                }
            }
        }
    }

    // MARK: Family prompt

    private func familyPromptCard(_ prompt: String) -> some View {
        SvaraCard {
            HStack(alignment: .top, spacing: SvaraTheme.Spacing.md) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.title3)
                    .foregroundStyle(SvaraTheme.Colors.primary)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text("A family conversation").svaraEyebrow()
                    Text(prompt)
                        .font(.svaraBody)
                        .foregroundStyle(SvaraTheme.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("A family conversation. \(prompt)")
    }

    // MARK: Related mantra / practice

    @ViewBuilder
    private var relatedSection: some View {
        if relatedMantra != nil || relatedPractice != nil {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
                Text("Bring it into practice").svaraEyebrow()
                if let mantra = relatedMantra {
                    NavigationLink {
                        MantraDetailView(mantra: mantra)
                    } label: {
                        relatedRow(icon: "waveform", title: mantra.title, subtitle: "Related mantra")
                    }
                    .buttonStyle(.plain)
                }
                if let practice = relatedPractice {
                    Button { activeCover = .practice(practice) } label: {
                        relatedRow(icon: practice.systemImage, title: practice.title, subtitle: "Related practice")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func relatedRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: SvaraTheme.Spacing.lg) {
            ZStack {
                Circle().fill(festival.theme.color.opacity(0.15)).frame(width: 44, height: 44)
                Image(systemName: icon).foregroundStyle(festival.theme.color)
            }
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(subtitle).svaraEyebrow()
                Text(title)
                    .font(.svaraHeadline)
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right").foregroundStyle(SvaraTheme.Colors.textSecondary)
        }
        .padding(SvaraTheme.Spacing.lg)
        .background(SvaraTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous)
                .strokeBorder(SvaraTheme.Colors.separator.opacity(0.7), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(subtitle): \(title)")
    }

    // MARK: More ways (the simple activity list)

    @ViewBuilder
    private var moreWaysSection: some View {
        if !festival.activities.isEmpty {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
                Text("More ways to mark it").svaraEyebrow()
                ForEach(Array(festival.activities.enumerated()), id: \.offset) { _, activity in
                    HStack(alignment: .top, spacing: SvaraTheme.Spacing.md) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundStyle(festival.theme.color)
                            .padding(.top, 7)
                            .accessibilityHidden(true)
                        Text(activity)
                            .font(.svaraBody)
                            .foregroundStyle(SvaraTheme.Colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    // MARK: Save / share (personal only — no public feed)

    private var saveShareRow: some View {
        HStack(spacing: SvaraTheme.Spacing.md) {
            let isSaved = env.isFestivalSaved(festival)
            Button { env.toggleFestivalSaved(festival) } label: {
                Label(isSaved ? "Saved" : "Save", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                    .font(.svaraHeadline)
                    .foregroundStyle(SvaraTheme.Colors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SvaraTheme.Spacing.md)
                    .background(SvaraTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous)
                        .strokeBorder(SvaraTheme.Colors.accent.opacity(0.25), lineWidth: 1.5))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isSaved ? "Saved for yourself" : "Save for yourself")

            if env.featureFlags.contentSharing {
                ShareLink(item: shareText) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.svaraHeadline)
                        .foregroundStyle(SvaraTheme.Colors.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, SvaraTheme.Spacing.md)
                        .background(SvaraTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous)
                            .strokeBorder(SvaraTheme.Colors.accent.opacity(0.25), lineWidth: 1.5))
                }
                .accessibilityLabel("Share this festival")
            }
        }
        .padding(.top, SvaraTheme.Spacing.sm)
    }

    private var shareText: String {
        "\(festival.name) — \(festival.shortContext)"
    }

    // MARK: Helpers

    private func section(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
            Text(title).svaraEyebrow()
            Text(body)
                .font(.svaraBody)
                .foregroundStyle(SvaraTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func traditionNote(_ note: String) -> some View {
        Text(note)
            .font(.svaraCaption)
            .italic()
            .foregroundStyle(SvaraTheme.Colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: festival.date)
    }

    private func loadRelated() async {
        if let id = festival.relatedMantraID {
            relatedMantra = await env.content.mantra(id: id)
        }
        if let id = festival.relatedPracticeID {
            let practices = await env.content.dailyPractices()
            if let practice = practices.first(where: { $0.id == id }) {
                relatedPractice = practice
                if let mid = practice.mantraID {
                    practiceMantra = await env.content.mantra(id: mid)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FestivalDetailView(festival: SeedContent.festivals[5]) // Diwali
            .environment(AppEnvironment.preview())
    }
}
