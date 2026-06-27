import SwiftUI

/// Stories & Symbols — deity tales organised by human themes like courage,
/// wisdom and devotion.
struct StoriesView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var viewModel = StoriesViewModel()
    @State private var showPaywall = false

    private let columns = [GridItem(.flexible(), spacing: SvaraTheme.Spacing.md),
                           GridItem(.flexible(), spacing: SvaraTheme.Spacing.md)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SvaraTheme.Spacing.lg) {
                    GreetingHeader(eyebrow: "STORIES & SYMBOLS", title: "Stories")
                    themeFilter

                    LazyVGrid(columns: columns, spacing: SvaraTheme.Spacing.md) {
                        ForEach(viewModel.filteredStories) { story in
                            let locked = story.isPremium && !env.isPremium
                            Group {
                                if locked {
                                    Button { showPaywall = true } label: {
                                        StoryCard(story: story, locked: true)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    NavigationLink {
                                        StoryDetailView(story: story)
                                    } label: {
                                        StoryCard(story: story, locked: false)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
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
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private var themeFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SvaraTheme.Spacing.sm) {
                Button { viewModel.selectedTheme = nil } label: {
                    Text("All")
                        .font(.svaraCaption.weight(.semibold))
                        .padding(.horizontal, SvaraTheme.Spacing.md)
                        .padding(.vertical, SvaraTheme.Spacing.sm)
                        .foregroundStyle(viewModel.selectedTheme == nil ? .white : SvaraTheme.Colors.accent)
                        .background(viewModel.selectedTheme == nil ? SvaraTheme.Colors.accent : SvaraTheme.Colors.accent.opacity(0.12))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                ForEach(viewModel.availableThemes) { theme in
                    Button {
                        viewModel.selectedTheme = viewModel.selectedTheme == theme ? nil : theme
                    } label: {
                        ThemeChip(theme: theme, isSelected: viewModel.selectedTheme == theme)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

private struct StoryCard: View {
    let story: StorySymbol
    let locked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous)
                    .fill(story.theme.color.opacity(0.18))
                    .frame(height: 90)
                Image(systemName: story.systemImage)
                    .font(.system(size: 34))
                    .foregroundStyle(story.theme.color)
                if locked {
                    VStack { HStack { Spacer(); PremiumBadge() }; Spacer() }
                        .padding(SvaraTheme.Spacing.sm)
                }
            }
            Text(story.theme.label.uppercased())
                .font(.svaraCaption.weight(.bold))
                .tracking(1)
                .foregroundStyle(story.theme.color)
            Text(story.title)
                .font(.svaraHeadline)
                .foregroundStyle(SvaraTheme.Colors.textPrimary)
                .lineLimit(2)
            Text(story.summary)
                .font(.svaraCaption)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
                .lineLimit(2)
            Label("\(story.readMinutes) min read", systemImage: "book")
                .font(.svaraCaption)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
        }
        .padding(SvaraTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SvaraTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous)
                .strokeBorder(SvaraTheme.Colors.separator.opacity(0.7), lineWidth: 1)
        )
    }
}

#Preview {
    StoriesView().environment(AppEnvironment.preview())
}
