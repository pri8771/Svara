import SwiftUI

/// Upcoming festival moments with their stories and simple ways to observe.
struct FestivalsView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var viewModel = FestivalsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xl) {
                    GreetingHeader(eyebrow: "FESTIVALS", title: "Moments")

                    if let next = viewModel.next {
                        SectionHeader(title: "Up next")
                        NavigationLink {
                            FestivalDetailView(festival: next)
                        } label: {
                            NextFestivalCard(festival: next)
                        }
                        .buttonStyle(.plain)
                    }

                    SectionHeader(title: "The year ahead")
                    LazyVStack(spacing: SvaraTheme.Spacing.md) {
                        ForEach(viewModel.festivals) { festival in
                            NavigationLink {
                                FestivalDetailView(festival: festival)
                            } label: {
                                FestivalRow(festival: festival, observed: env.isFestivalObserved(festival))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, SvaraTheme.Spacing.screenMargin)
                .padding(.vertical, SvaraTheme.Spacing.lg)
            }
            .svaraScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
        .task { await viewModel.load(content: env.content) }
    }
}

private struct NextFestivalCard: View {
    let festival: Festival

    var body: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
            HStack {
                Image(systemName: festival.systemImage)
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                Spacer()
                Text(countdownLabel)
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
            Text(festival.tagline)
                .font(.svaraBody)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(SvaraTheme.Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SvaraTheme.Gradients.dusk)
        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous))
        .shadow(color: SvaraTheme.Palette.indigo.opacity(0.3), radius: 16, y: 8)
    }

    private var countdownLabel: String {
        let days = festival.daysUntil()
        if days == 0 { return "Today" }
        if days == 1 { return "Tomorrow" }
        return "in \(days) days"
    }
}

private struct FestivalRow: View {
    let festival: Festival
    let observed: Bool

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
            VStack(alignment: .leading, spacing: 4) {
                Text(festival.name)
                    .font(.svaraHeadline)
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)
                Text(dateLabel)
                    .font(.svaraCallout)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
            }
            Spacer(minLength: 0)
            if observed {
                Image(systemName: "checkmark.seal.fill")
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
    }

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: festival.date)
    }
}

#Preview {
    FestivalsView().environment(AppEnvironment.preview())
}
