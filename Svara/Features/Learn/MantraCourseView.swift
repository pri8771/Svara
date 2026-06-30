import SwiftUI

/// A single "chapter" of the Aaroh Path: all the lessons that teach one mantra,
/// shown as a vertical path of nodes (completed / current / locked) with an
/// **insight preview** — what meaning each step will unlock once completed.
struct MantraCourseView: View {
    @Environment(AppEnvironment.self) private var env

    let title: String
    let subtitle: String?
    /// The lessons in this course, already in path order.
    let lessons: [Lesson]
    /// The full lesson set, used to compute unlock state across the whole path.
    let allLessons: [Lesson]

    @State private var activeLesson: Lesson?
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.lg) {
                if let subtitle {
                    Text(subtitle)
                        .font(.svaraBody)
                        .foregroundStyle(SvaraTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                ForEach(Array(lessons.enumerated()), id: \.element.id) { idx, lesson in
                    CourseNodeRow(
                        lesson: lesson,
                        state: state(for: lesson),
                        isPremiumLocked: isPremiumLocked(lesson),
                        isLast: idx == lessons.count - 1
                    ) {
                        open(lesson)
                    }
                }
            }
            .padding(.horizontal, SvaraTheme.Spacing.screenMargin)
            .padding(.vertical, SvaraTheme.Spacing.lg)
        }
        .svaraScreenBackground()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $activeLesson) { LessonPlayerView(lesson: $0) }
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private func state(for lesson: Lesson) -> LessonNodeState {
        AarohPath.state(for: lesson, in: allLessons, completedIDs: env.completedLessonIDs)
    }

    private func isPremiumLocked(_ lesson: Lesson) -> Bool {
        lesson.isPremium && !env.isPremium
    }

    private func open(_ lesson: Lesson) {
        if isPremiumLocked(lesson) {
            showPaywall = true
            return
        }
        // Allow starting the current step or revisiting completed ones.
        let unlocked = AarohPath.isUnlocked(lesson, in: allLessons, completedIDs: env.completedLessonIDs)
        if unlocked { activeLesson = lesson }
    }
}

/// One node in a course: number/state badge, title, and an insight preview.
private struct CourseNodeRow: View {
    let lesson: Lesson
    let state: LessonNodeState
    let isPremiumLocked: Bool
    let isLast: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: SvaraTheme.Spacing.lg) {
                nodeColumn
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        if let day = lesson.pathDay {
                            Text("Day \(day)").svaraEyebrow()
                        } else {
                            Text("Lesson \(lesson.level)").svaraEyebrow()
                        }
                        if isPremiumLocked { PremiumBadge() }
                    }
                    Text(lesson.title)
                        .font(.svaraHeadline)
                        .foregroundStyle(SvaraTheme.Colors.textPrimary)
                    insightPreview
                    statusLabel
                }
                Spacer(minLength: 0)
                Image(systemName: trailingIcon)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
                    .accessibilityHidden(true)
            }
        }
        .buttonStyle(.plain)
        .padding(SvaraTheme.Spacing.lg)
        .background(SvaraTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SvaraTheme.Radius.lg, style: .continuous)
                .strokeBorder(state == .current ? SvaraTheme.Colors.primary : SvaraTheme.Colors.separator.opacity(0.7),
                              lineWidth: state == .current ? 2 : 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }

    // Insight preview: reveal the meaning once completed; tease it before.
    @ViewBuilder
    private var insightPreview: some View {
        if let insightTitle = lesson.insightTitle {
            if state == .completed, let body = lesson.insightBody {
                Text(body)
                    .font(.svaraCallout)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Label("You'll unlock: \(insightTitle)", systemImage: "lock.fill")
                    .font(.svaraCallout)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
            }
        } else {
            Text(lesson.subtitle)
                .font(.svaraCallout)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
        }
    }

    @ViewBuilder
    private var statusLabel: some View {
        switch state {
        case .completed:
            Label("Completed", systemImage: "checkmark.circle.fill")
                .font(.svaraCaption.weight(.semibold))
                .foregroundStyle(SvaraTheme.Colors.success)
        case .current:
            Label("Start now · about a minute", systemImage: "play.circle.fill")
                .font(.svaraCaption.weight(.semibold))
                .foregroundStyle(SvaraTheme.Colors.primaryDeep)
        case .locked:
            Label("Opens after the step before", systemImage: "lock")
                .font(.svaraCaption)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
        }
    }

    private var nodeColumn: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(nodeFill)
                    .frame(width: 44, height: 44)
                Image(systemName: nodeIcon)
                    .font(.headline)
                    .foregroundStyle(nodeForeground)
            }
            if !isLast {
                Rectangle()
                    .fill(SvaraTheme.Colors.separator)
                    .frame(width: 2, height: 26)
            }
        }
        .accessibilityHidden(true)
    }

    private var nodeFill: Color {
        switch state {
        case .completed: return SvaraTheme.Colors.success
        case .current: return lesson.theme.color.opacity(0.18)
        case .locked: return SvaraTheme.Colors.separator.opacity(0.4)
        }
    }

    private var nodeForeground: Color {
        switch state {
        case .completed: return .white
        case .current: return lesson.theme.color
        case .locked: return SvaraTheme.Colors.textSecondary
        }
    }

    private var nodeIcon: String {
        if isPremiumLocked { return "lock.fill" }
        switch state {
        case .completed: return "checkmark"
        case .current: return lesson.theme.systemImage
        case .locked: return "lock.fill"
        }
    }

    private var trailingIcon: String {
        switch state {
        case .completed: return "arrow.clockwise"
        case .current: return "chevron.right"
        case .locked: return "lock.fill"
        }
    }

    private var accessibilityLabel: String {
        let dayPart = lesson.pathDay.map { "Day \($0), " } ?? ""
        let statePart: String
        switch state {
        case .completed: statePart = "completed"
        case .current: statePart = "current step, start now"
        case .locked: statePart = "locked, opens after the previous step"
        }
        return "\(dayPart)\(lesson.title), \(statePart)"
    }

    private var accessibilityHint: String {
        switch state {
        case .completed: return "Revisit this step"
        case .current: return "Takes about a minute"
        case .locked: return isPremiumLocked ? "Requires Svara Plus" : ""
        }
    }
}

#Preview {
    NavigationStack {
        MantraCourseView(
            title: "Vakratunda",
            subtitle: "A prayer before beginnings.",
            lessons: Array(SeedContent.lessons[2...4]),
            allLessons: SeedContent.lessons
        )
        .environment(AppEnvironment.preview())
    }
}
