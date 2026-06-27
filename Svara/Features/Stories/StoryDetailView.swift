import SwiftUI

struct StoryDetailView: View {
    let story: StorySymbol

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xl) {
                hero
                section(title: "The story", body: story.story)

                SvaraCard(background: story.theme.color.opacity(0.1)) {
                    VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
                        Label("What it means", systemImage: story.theme.systemImage)
                            .font(.svaraHeadline)
                            .foregroundStyle(story.theme.color)
                        Text(story.symbolMeaning)
                            .font(.svaraBody)
                            .foregroundStyle(SvaraTheme.Colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
                    Text("Carry this with you").svaraEyebrow()
                    Text("“\(story.takeaway)”")
                        .font(.svaraTitle)
                        .foregroundStyle(SvaraTheme.Colors.accent)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, SvaraTheme.Spacing.screenMargin)
            .padding(.vertical, SvaraTheme.Spacing.lg)
        }
        .svaraScreenBackground()
        .navigationTitle(story.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
            HStack {
                Image(systemName: story.systemImage)
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
                Spacer()
                Label(story.deity, systemImage: "leaf.fill")
                    .font(.svaraCallout)
                    .foregroundStyle(.white.opacity(0.9))
            }
            Text(story.title)
                .font(.svaraDisplay)
                .foregroundStyle(.white)
            Text(story.summary)
                .font(.svaraBody)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(SvaraTheme.Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [story.theme.color, story.theme.color.opacity(0.7)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous))
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
}

#Preview {
    NavigationStack {
        StoryDetailView(story: SeedContent.stories[0])
    }
}
