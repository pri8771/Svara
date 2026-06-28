import SwiftUI

/// The Festivals home: seasonal cultural *moments*, not a calendar. An upcoming
/// hero with a countdown, a "Coming soon" rail, a "This season" section, the
/// full year ahead, and a gentle regional lens. Tapping any moment opens its
/// detail.
struct FestivalsView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var viewModel = FestivalsViewModel()

    var body: some View {
        @Bindable var vm = viewModel
        return NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xl) {
                    GreetingHeader(eyebrow: "FESTIVALS", title: "Festival Moments")

                    if viewModel.isLoading {
                        ProgressView().frame(maxWidth: .infinity).padding(.vertical, SvaraTheme.Spacing.xxl)
                    } else {
                        RegionFilterView(selection: $vm.selectedRegion)

                        if let next = viewModel.next {
                            heroSection(next)
                            comingSoonSection
                            thisSeasonSection
                            yearAheadSection
                        } else {
                            emptyState
                            yearAheadSection
                        }
                    }
                }
                .padding(.horizontal, SvaraTheme.Spacing.screenMargin)
                .padding(.vertical, SvaraTheme.Spacing.lg)
            }
            .svaraScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Festival.self) { festival in
                FestivalDetailView(festival: festival)
            }
        }
        .task { await viewModel.load(content: env.content) }
    }

    // MARK: Hero

    private func heroSection(_ festival: Festival) -> some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
            Text("UP NEXT").svaraEyebrow()
            NavigationLink(value: festival) {
                HeroFestivalCard(festival: festival, daysUntil: viewModel.daysUntil(festival))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Coming soon (horizontal rail)

    @ViewBuilder
    private var comingSoonSection: some View {
        let items = viewModel.comingSoon()
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
                SectionHeader(title: "Coming soon")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: SvaraTheme.Spacing.md) {
                        ForEach(items) { festival in
                            NavigationLink(value: festival) {
                                FestivalMomentCard(festival: festival, daysUntil: viewModel.daysUntil(festival))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
    }

    // MARK: This season

    @ViewBuilder
    private var thisSeasonSection: some View {
        let items = viewModel.thisSeason
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
                SectionHeader(title: "This season",
                              subtitle: "\(viewModel.currentSeason.label) moments to look forward to")
                LazyVStack(spacing: SvaraTheme.Spacing.md) {
                    ForEach(items) { festival in
                        NavigationLink(value: festival) {
                            FestivalRow(festival: festival,
                                        daysUntil: viewModel.daysUntil(festival),
                                        observed: env.hasCompletedFestivalActivity(festival),
                                        dimmed: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: The year ahead (region-ordered, nothing hidden)

    private var yearAheadSection: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
            SectionHeader(title: "The year ahead",
                          subtitle: viewModel.selectedRegion == nil ? nil : "Sorted for \(viewModel.selectedRegion!.label) — nothing hidden")
            LazyVStack(spacing: SvaraTheme.Spacing.md) {
                ForEach(viewModel.yearAhead) { festival in
                    NavigationLink(value: festival) {
                        FestivalRow(festival: festival,
                                    daysUntil: viewModel.daysUntil(festival),
                                    observed: env.hasCompletedFestivalActivity(festival),
                                    dimmed: !viewModel.matchesSelectedRegion(festival))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Empty state

    private var emptyState: some View {
        EmptyStateView(
            systemImage: "sparkles",
            title: "No festival on the horizon",
            message: "There's nothing in the immediate calendar — but the year ahead is below. Traditions and dates vary, so check back as the seasons turn."
        )
    }
}

// MARK: - Hero card

private struct HeroFestivalCard: View {
    let festival: Festival
    let daysUntil: Int

    var body: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
            HStack(alignment: .top) {
                Image(systemName: festival.systemImage)
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                Spacer()
                Text(FestivalCountdown.label(daysUntil: daysUntil))
                    .font(.svaraHeadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, SvaraTheme.Spacing.md)
                    .padding(.vertical, SvaraTheme.Spacing.sm)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
            }
            Text(festival.name)
                .font(.svaraDisplay)
                .foregroundStyle(.white)
            Text(festival.shortContext)
                .font(.svaraBody)
                .foregroundStyle(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 6) {
                Text("Explore")
                Image(systemName: "arrow.right")
            }
            .font(.svaraHeadline)
            .foregroundStyle(.white)
            .padding(.top, SvaraTheme.Spacing.xs)
        }
        .padding(SvaraTheme.Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SvaraTheme.Gradients.dusk)
        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous))
        .shadow(color: SvaraTheme.Palette.indigo.opacity(0.3), radius: 16, y: 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Up next: \(festival.name), \(FestivalCountdown.label(daysUntil: daysUntil)). \(festival.shortContext). Explore.")
    }
}

// MARK: - Row

private struct FestivalRow: View {
    let festival: Festival
    let daysUntil: Int
    let observed: Bool
    var dimmed: Bool = false

    var body: some View {
        HStack(spacing: SvaraTheme.Spacing.lg) {
            ZStack {
                RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous)
                    .fill(festival.theme.color.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: festival.systemImage)
                    .font(.title3)
                    .foregroundStyle(festival.theme.color)
            }
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(festival.name)
                    .font(.svaraHeadline)
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)
                HStack(spacing: SvaraTheme.Spacing.sm) {
                    Text(dateLabel)
                    Text("·")
                    Text(FestivalCountdown.label(daysUntil: daysUntil))
                }
                .font(.svaraCallout)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
            }
            Spacer(minLength: 0)
            if observed {
                Label("Done", systemImage: "checkmark.seal.fill")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(SvaraTheme.Colors.success)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
            }
        }
        .padding(SvaraTheme.Spacing.lg)
        .background(SvaraTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous)
                .strokeBorder(SvaraTheme.Colors.separator.opacity(0.7), lineWidth: 1)
        )
        .opacity(dimmed ? 0.55 : 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(festival.name), \(dateLabel), \(FestivalCountdown.label(daysUntil: daysUntil))\(observed ? ", activity completed" : "")")
    }

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: festival.date)
    }
}

#Preview {
    FestivalsView().environment(AppEnvironment.preview())
}
