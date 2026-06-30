import SwiftUI

/// A compact story card: an illustrated gradient header in the theme colour,
/// the title, a theme chip, the deity, and a read-time badge. No hearts, lives,
/// or streak mechanics.
struct StoryCardView: View {
    let story: Story

    var body: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [story.theme.color, story.theme.color.opacity(0.7)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 96)
                Image(systemName: story.theme.systemImage)
                    .font(.system(size: 40))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(SvaraTheme.Spacing.md)
            }
            .accessibilityHidden(true)

            HStack(spacing: 6) {
                Image(systemName: story.theme.systemImage)
                Text(story.theme.label)
            }
            .font(.svaraCaption.weight(.bold))
            .foregroundStyle(story.theme.color)

            Text(story.title)
                .font(.svaraHeadline)
                .foregroundStyle(SvaraTheme.Colors.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(story.deity)
                .font(.svaraCaption)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)

            Label(story.durationLabel, systemImage: "book")
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(story.title), about \(story.deity), theme \(story.theme.label), \(story.durationLabel)")
    }
}

#Preview {
    StoryCardView(story: SeedContent.storyLibrary[0])
        .frame(width: 200)
        .padding()
        .background(SvaraTheme.Colors.background)
}
