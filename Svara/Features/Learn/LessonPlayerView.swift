import SwiftUI

/// Steps a user through a lesson one card at a time, with interactive quiz
/// steps, then awards XP on completion.
struct LessonPlayerView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss

    let lesson: Lesson

    @State private var index = 0
    @State private var selectedOption: Int?
    @State private var hasChecked = false
    @State private var correctCount = 0
    @State private var finished = false

    private var step: LessonStep { lesson.steps[index] }
    private var isLastStep: Bool { index == lesson.steps.count - 1 }

    var body: some View {
        VStack(spacing: SvaraTheme.Spacing.lg) {
            topBar
            if finished {
                completionView
            } else {
                stepContent
                Spacer()
                actionButton
            }
        }
        .padding(SvaraTheme.Spacing.screenMargin)
        .svaraScreenBackground()
    }

    // MARK: Top bar with progress

    private var topBar: some View {
        HStack(spacing: SvaraTheme.Spacing.md) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
            }
            ProgressView(value: progress)
                .tint(SvaraTheme.Colors.primary)
        }
    }

    private var progress: Double {
        finished ? 1 : Double(index) / Double(max(1, lesson.steps.count))
    }

    // MARK: Step content

    @ViewBuilder
    private var stepContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.lg) {
                ThemeChip(theme: lesson.theme)
                Text(step.prompt)
                    .font(.svaraTitle)
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)

                if let detail = step.detail {
                    Text(detail)
                        .font(.svaraBody)
                        .foregroundStyle(SvaraTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if step.kind == .listen {
                    listenCard
                }

                if step.isInteractive {
                    optionsView
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, SvaraTheme.Spacing.md)
        }
    }

    private var listenCard: some View {
        SvaraCard(background: SvaraTheme.Colors.surfaceInverse) {
            HStack {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.title2)
                    .foregroundStyle(SvaraTheme.Colors.points)
                Text("Chant along softly")
                    .font(.svaraHeadline)
                    .foregroundStyle(SvaraTheme.Colors.textOnDark)
                Spacer()
            }
        }
    }

    private var optionsView: some View {
        VStack(spacing: SvaraTheme.Spacing.md) {
            ForEach(Array(step.options.enumerated()), id: \.offset) { i, option in
                Button {
                    if !hasChecked { selectedOption = i }
                } label: {
                    HStack {
                        Text(option)
                            .font(.svaraHeadline)
                            .foregroundStyle(SvaraTheme.Colors.textPrimary)
                        Spacer()
                        if hasChecked, i == step.correctIndex {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(SvaraTheme.Colors.success)
                        } else if hasChecked, i == selectedOption {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                        }
                    }
                    .padding(SvaraTheme.Spacing.lg)
                    .background(optionBackground(i))
                    .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous)
                            .strokeBorder(optionBorder(i), lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func optionBackground(_ i: Int) -> Color {
        if hasChecked {
            if i == step.correctIndex { return SvaraTheme.Colors.success.opacity(0.15) }
            if i == selectedOption { return Color.red.opacity(0.1) }
        } else if i == selectedOption {
            return SvaraTheme.Colors.primary.opacity(0.12)
        }
        return SvaraTheme.Colors.surface
    }

    private func optionBorder(_ i: Int) -> Color {
        if i == selectedOption { return SvaraTheme.Colors.primary }
        return SvaraTheme.Colors.separator
    }

    // MARK: Action button

    @ViewBuilder
    private var actionButton: some View {
        if step.isInteractive && !hasChecked {
            PrimaryButton(title: "Check", isEnabled: selectedOption != nil) { check() }
        } else {
            PrimaryButton(title: isLastStep ? "Finish" : "Continue") { advance() }
        }
    }

    private func check() {
        hasChecked = true
        if selectedOption == step.correctIndex { correctCount += 1 }
    }

    private func advance() {
        if isLastStep {
            env.completeLesson(lesson)
            withAnimation { finished = true }
        } else {
            withAnimation {
                index += 1
                selectedOption = nil
                hasChecked = false
            }
        }
    }

    // MARK: Completion

    private var completionView: some View {
        VStack(spacing: SvaraTheme.Spacing.lg) {
            Spacer()
            Image(systemName: "star.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(SvaraTheme.Colors.points)
            Text("Lesson complete!")
                .font(.svaraDisplay)
                .foregroundStyle(SvaraTheme.Colors.textPrimary)
            Text("You earned +\(lesson.xp) XP")
                .font(.svaraHeadline)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
            let quizzes = lesson.steps.filter { $0.isInteractive }.count
            if quizzes > 0 {
                Text("\(correctCount)/\(quizzes) correct")
                    .font(.svaraBody)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
            }
            Spacer()
            PrimaryButton(title: "Done") { dismiss() }
        }
    }
}

#Preview {
    LessonPlayerView(lesson: SeedContent.lessons[0])
        .environment(AppEnvironment.preview())
}
