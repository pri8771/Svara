import SwiftUI

/// The Stories & Symbols tab: a calm, unhurried library of deity stories and
/// symbols, browsable by theme and search, with a daily featured story.
struct StoriesHomeView: View {
    @Environment(AppEnvironment.self) private var env
    @StateObject private var viewModel = StoriesViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: SvaraTheme.Spacing.md),
        GridItem(.flexible(), spacing: SvaraTheme.Spacing.md)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SvaraTheme.Spacing.lg) {
                    GreetingHeader(eyebrow: "STORIES & SYMBOLS", title: "Stories")

                    if let featured = viewModel.featuredStory, viewModel.searchText.isEmpty, viewModel.selectedTheme == nil {
                        featuredHero(featured)
                    }

                    searchBar
                    themeFilter

                    let results = viewModel.filtered()
                    if results.isEmpty {
                        EmptyStateView(
                            systemImage: "book.closed",
                            title: "Nothing here yet",
                            message: "No stories match that just now. Try another theme or a different word."
                        )
                    } else {
                        LazyVGrid(columns: columns, spacing: SvaraTheme.Spacing.md) {
                            ForEach(results) { story in
                                NavigationLink(value: story) {
                                    StoryCardView(story: story)
                                }
                                .buttonStyle(.plain)
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
            .navigationDestination(for: Story.self) { story in
                StoryDetailView(story: story)
            }
        }
        .task { viewModel.load(service: env.storyLibrary) }
    }

    // MARK: Featured hero

    private func featuredHero(_ story: Story) -> some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
            Text("TODAY'S STORY").svaraEyebrow()
            NavigationLink(value: story) {
                VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: story.theme.systemImage)
                            Text(story.theme.label)
                        }
                        .font(.svaraCaption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, SvaraTheme.Spacing.sm)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                        Spacer()
                        Label(story.deity, systemImage: "leaf.fill")
                            .font(.svaraCallout)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    Text(story.title)
                        .font(.svaraDisplay)
                        .foregroundStyle(.white)
                    Text(story.moralOrMeaning)
                        .font(.svaraCallout)
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 6) {
                        Text("Read now")
                        Image(systemName: "arrow.right")
                    }
                    .font(.svaraHeadline)
                    .foregroundStyle(.white)
                    .padding(.top, SvaraTheme.Spacing.xs)
                }
                .padding(SvaraTheme.Spacing.xl)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(colors: [story.theme.color, story.theme.color.opacity(0.7)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous))
                .shadow(color: story.theme.color.opacity(0.3), radius: 16, y: 8)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Today's story: \(story.title), about \(story.deity). \(story.moralOrMeaning). Read now.")
        }
    }

    // MARK: Search

    private var searchBar: some View {
        HStack(spacing: SvaraTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
            TextField("Search stories, deities, themes", text: $viewModel.searchText)
                .font(.svaraBody)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            if !viewModel.searchText.isEmpty {
                Button { viewModel.searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(SvaraTheme.Colors.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(SvaraTheme.Spacing.md)
        .background(SvaraTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous)
                .strokeBorder(SvaraTheme.Colors.separator.opacity(0.7), lineWidth: 1)
        )
    }

    // MARK: Theme chips

    private var themeFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SvaraTheme.Spacing.sm) {
                chip(label: "All", systemImage: "square.grid.2x2",
                     tint: SvaraTheme.Colors.accent, isSelected: viewModel.selectedTheme == nil) {
                    viewModel.selectedTheme = nil
                }
                ForEach(viewModel.availableThemes) { theme in
                    chip(label: theme.label, systemImage: theme.systemImage,
                         tint: theme.color, isSelected: viewModel.selectedTheme == theme) {
                        viewModel.selectedTheme = (viewModel.selectedTheme == theme) ? nil : theme
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func chip(label: String, systemImage: String, tint: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(label)
            }
            .font(.svaraCaption.weight(.semibold))
            .foregroundStyle(isSelected ? .white : tint)
            .padding(.horizontal, SvaraTheme.Spacing.md)
            .padding(.vertical, SvaraTheme.Spacing.sm)
            .background(isSelected ? tint : tint.opacity(0.12))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    StoriesHomeView().environment(AppEnvironment.preview())
}
