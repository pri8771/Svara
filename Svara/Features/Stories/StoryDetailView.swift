import SwiftUI

/// A full story reader: header with deity/theme/duration and a tradition note,
/// the story body, a symbolism rail, a humble meaning callout, a reflection
/// prompt with private journaling, and optional related links.
struct StoryDetailView: View {
    @Environment(AppEnvironment.self) private var env
    let story: Story

    @State private var reflections: [ReflectionEntry] = []
    @State private var showReflection = false
    @State private var relatedLesson: Lesson?
    @State private var relatedFestival: Festival?
    @State private var activeLesson: Lesson?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xl) {
                header
                StoryMarkdownText(markdown: story.bodyMarkdown)
                if !story.symbolism.isEmpty { symbolismSection }
                meaningCallout
                reflectionSection
                relatedSection
            }
            .padding(.horizontal, SvaraTheme.Spacing.screenMargin)
            .padding(.vertical, SvaraTheme.Spacing.lg)
        }
        .svaraScreenBackground()
        .navigationTitle(story.deity)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showReflection) {
            ReflectionPromptView(story: story) { reflections = env.reflections.entries(for: story.id) }
        }
        .fullScreenCover(item: $activeLesson) { LessonPlayerView(lesson: $0) }
        .task {
            reflections = env.reflections.entries(for: story.id)
            await loadRelated()
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
                HStack {
                    Image(systemName: story.theme.systemImage)
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                    Spacer()
                    Label(story.deity, systemImage: "leaf.fill")
                        .font(.svaraCallout)
                        .foregroundStyle(.white.opacity(0.9))
                }
                Text(story.title)
                    .font(.svaraDisplay)
                    .foregroundStyle(.white)
                HStack(spacing: SvaraTheme.Spacing.sm) {
                    chip(story.theme.label, system: story.theme.systemImage)
                    chip(story.durationLabel, system: "book")
                }
            }
            .padding(SvaraTheme.Spacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(colors: [story.theme.color, story.theme.color.opacity(0.7)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous))

            Text(story.traditionNote)
                .font(.svaraCaption)
                .italic()
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(story.title), about \(story.deity). \(story.traditionNote)")
    }

    private func chip(_ text: String, system: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: system)
            Text(text)
        }
        .font(.svaraCaption.weight(.semibold))
        .foregroundStyle(.white)
        .padding(.horizontal, SvaraTheme.Spacing.sm)
        .padding(.vertical, 4)
        .background(.white.opacity(0.2))
        .clipShape(Capsule())
    }

    // MARK: Symbolism

    private var symbolismSection: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
            Text("Symbols in this story").svaraEyebrow()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SvaraTheme.Spacing.md) {
                    ForEach(story.symbolism) { symbol in
                        SymbolCard(symbol: symbol, tint: story.theme.color)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    // MARK: Meaning callout

    private var meaningCallout: some View {
        SvaraCard(background: story.theme.color.opacity(0.10)) {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
                Label("One way to understand this", systemImage: story.theme.systemImage)
                    .font(.svaraHeadline)
                    .foregroundStyle(story.theme.color)
                Text(story.moralOrMeaning)
                    .font(.svaraBody)
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("One way to understand this. \(story.moralOrMeaning)")
    }

    // MARK: Reflection

    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
            Text("A moment to reflect").svaraEyebrow()
            Text(story.reflectionPrompt)
                .font(.svaraTitle)
                .foregroundStyle(SvaraTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(reflections) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.text)
                        .font(.svaraBody)
                        .foregroundStyle(SvaraTheme.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(dateLabel(entry.createdAt))
                        .font(.svaraCaption)
                        .foregroundStyle(SvaraTheme.Colors.textSecondary)
                }
                .padding(SvaraTheme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SvaraTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous)
                        .strokeBorder(SvaraTheme.Colors.separator.opacity(0.7), lineWidth: 1)
                )
            }

            SecondaryButton(title: reflections.isEmpty ? "Add a reflection" : "Add another reflection",
                            systemImage: "square.and.pencil") {
                showReflection = true
            }
        }
    }

    // MARK: Related

    @ViewBuilder
    private var relatedSection: some View {
        if relatedLesson != nil || relatedFestival != nil {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
                Text("Carry it further").svaraEyebrow()
                if let lesson = relatedLesson {
                    Button { activeLesson = lesson } label: {
                        relatedRow(icon: "graduationcap.fill", title: "Practice this in Aaroh", subtitle: lesson.title)
                    }
                    .buttonStyle(.plain)
                }
                if let festival = relatedFestival {
                    NavigationLink {
                        FestivalDetailView(festival: festival)
                    } label: {
                        relatedRow(icon: "sparkles", title: "See the festival", subtitle: festival.name)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func relatedRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: SvaraTheme.Spacing.lg) {
            ZStack {
                Circle().fill(story.theme.color.opacity(0.15)).frame(width: 44, height: 44)
                Image(systemName: icon).foregroundStyle(story.theme.color)
            }
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.svaraHeadline)
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)
                Text(subtitle)
                    .font(.svaraCallout)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
                    .lineLimit(1)
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
        .accessibilityLabel("\(title): \(subtitle)")
    }

    // MARK: Helpers

    private func dateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func loadRelated() async {
        if let id = story.relatedMantraId {
            relatedLesson = (await env.content.lessons()).first { $0.id == id }
        }
        if let id = story.relatedFestivalId {
            relatedFestival = (await env.content.festivals()).first { $0.id == id }
        }
    }
}

/// Lightweight markdown renderer: splits on blank lines and renders each
/// paragraph (with inline bold/italic) or a `## ` heading. No external packages.
struct StoryMarkdownText: View {
    let markdown: String

    var body: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                if block.hasPrefix("## ") {
                    Text(String(block.dropFirst(3)))
                        .font(.svaraTitle)
                        .foregroundStyle(SvaraTheme.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(attributed(block))
                        .font(.svaraBody)
                        .foregroundStyle(SvaraTheme.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var blocks: [String] {
        markdown
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func attributed(_ string: String) -> AttributedString {
        (try? AttributedString(
            markdown: string,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(string)
    }
}

#Preview {
    NavigationStack {
        StoryDetailView(story: SeedContent.storyLibrary[0])
            .environment(AppEnvironment.preview())
    }
}
