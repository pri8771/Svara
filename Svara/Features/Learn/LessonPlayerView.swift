import SwiftUI

/// Steps a learner through a lesson one card at a time. Supports reading cards
/// (intro/listen/meaning/reflection) and three interactive step types
/// (matchMeaning/multipleChoice, fillBlank, syllableOrder).
///
/// Feedback is **gentle and forgiving** (ProductGuardrails §8.2): a non-matching
/// answer is never "wrong" — the learner sees the correct answer kindly, with an
/// encouraging line, and always continues. No lives, hearts, or failure states.
struct LessonPlayerView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss

    let lesson: Lesson

    @State private var index = 0
    @State private var hasChecked = false
    @State private var correctCount = 0
    @State private var finished = false

    // Per-step answer state (reset on advance).
    @State private var selectedOption: Int?
    @State private var builtSyllables: [String] = []
    @State private var poolSyllables: [String] = []
    @State private var hintShown = false
    @State private var lastAnswerMatched = false
    @State private var wrongAttempts = 0

    private var step: LessonStep { lesson.steps[index] }
    private var isLastStep: Bool { index == lesson.steps.count - 1 }

    var body: some View {
        VStack(spacing: SvaraTheme.Spacing.lg) {
            topBar
            if finished {
                LessonResultView(lesson: lesson, correctCount: correctCount) { dismiss() }
            } else {
                stepContent
                Spacer(minLength: 0)
                feedbackBanner
                actionButton
            }
        }
        .padding(SvaraTheme.Spacing.screenMargin)
        .svaraScreenBackground()
        .onAppear(perform: syncSyllablePool)
    }

    // MARK: Top bar with progress

    private var topBar: some View {
        HStack(spacing: SvaraTheme.Spacing.md) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
            }
            .accessibilityLabel("Close lesson")
            ProgressView(value: progress)
                .tint(SvaraTheme.Colors.primary)
                .accessibilityLabel("Lesson progress")
                .accessibilityValue("\(Int(progress * 100)) percent")
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

                switch step.kind {
                case .listen:
                    listenCard
                case .multipleChoice, .matchMeaning, .fillBlank:
                    optionsView
                case .syllableOrder:
                    syllableBuilder
                case .intro, .meaning, .reflection:
                    EmptyView()
                }

                if step.hint != nil && step.isInteractive {
                    hintView
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
                Text(LearnCopy.chantAlong)
                    .font(.svaraHeadline)
                    .foregroundStyle(SvaraTheme.Colors.textOnDark)
                Spacer()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(LearnCopy.chantAlong)
    }

    // MARK: Option-based steps

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
                            .multilineTextAlignment(.leading)
                        Spacer()
                        optionStateIcon(i)
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
                .disabled(hasChecked)
                .accessibilityLabel(option)
                .accessibilityValue(optionAccessibilityValue(i))
                .accessibilityAddTraits(selectedOption == i ? .isSelected : [])
            }
        }
    }

    /// Icon (not colour alone) communicating an option's state after checking.
    @ViewBuilder
    private func optionStateIcon(_ i: Int) -> some View {
        if hasChecked, i == step.correctIndex {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(SvaraTheme.Colors.success)
        } else if hasChecked, i == selectedOption, i != step.correctIndex {
            // Gentle, non-punitive marker for the learner's pick (no red ✗).
            Image(systemName: "arrow.up.circle")
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
        } else if !hasChecked, i == selectedOption {
            Image(systemName: "circle.fill")
                .foregroundStyle(SvaraTheme.Colors.primary)
        }
    }

    private func optionAccessibilityValue(_ i: Int) -> String {
        guard hasChecked else { return "" }
        if i == step.correctIndex { return "Correct answer" }
        if i == selectedOption { return "Your choice" }
        return ""
    }

    private func optionBackground(_ i: Int) -> Color {
        if hasChecked {
            if i == step.correctIndex { return SvaraTheme.Colors.success.opacity(0.15) }
            if i == selectedOption { return SvaraTheme.Colors.primary.opacity(0.06) }
        } else if i == selectedOption {
            return SvaraTheme.Colors.primary.opacity(0.12)
        }
        return SvaraTheme.Colors.surface
    }

    private func optionBorder(_ i: Int) -> Color {
        if hasChecked, i == step.correctIndex { return SvaraTheme.Colors.success }
        if i == selectedOption { return SvaraTheme.Colors.primary }
        return SvaraTheme.Colors.separator
    }

    // MARK: Syllable ordering

    private var syllableBuilder: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.md) {
            Text(LearnCopy.arrangeSyllables).svaraEyebrow()

            // The line being built.
            FlowChips(items: builtSyllables, emptyHint: "Tap below to begin") { tapped in
                guard !hasChecked else { return }
                returnSyllable(tapped)
            }
            .accessibilityLabel("Your arrangement")
            .accessibilityValue(builtSyllables.isEmpty ? "Empty" : builtSyllables.joined(separator: ", "))

            Divider().background(SvaraTheme.Colors.separator)

            // The pool of available syllables.
            FlowChips(items: poolSyllables, emptyHint: "", filled: true) { tapped in
                guard !hasChecked else { return }
                chooseSyllable(tapped)
            }
            .accessibilityLabel("Available syllables")

            if hasChecked, !lastAnswerMatched {
                Text("In order: \(step.syllables.joined(separator: " · "))")
                    .font(.svaraCallout.weight(.semibold))
                    .foregroundStyle(SvaraTheme.Colors.success)
                    .accessibilityLabel("The order is \(step.syllables.joined(separator: ", "))")
            }
        }
    }

    private func chooseSyllable(_ s: String) {
        if let idx = poolSyllables.firstIndex(of: s) {
            poolSyllables.remove(at: idx)
            builtSyllables.append(s)
        }
    }

    private func returnSyllable(_ s: String) {
        if let idx = builtSyllables.firstIndex(of: s) {
            builtSyllables.remove(at: idx)
            poolSyllables.append(s)
        }
    }

    /// Presents the syllables in a stable, non-correct order (no randomness so
    /// previews and tests stay deterministic).
    private func syncSyllablePool() {
        guard step.kind == .syllableOrder else { return }
        let correct = step.syllables
        let scrambled = correct.reversed().map { $0 }
        // If reversing happens to equal the answer (palindrome-ish), rotate.
        poolSyllables = (scrambled == correct && correct.count > 1)
            ? Array(correct[1...]) + [correct[0]]
            : scrambled
        builtSyllables = []
    }

    // MARK: Hint

    @ViewBuilder
    private var hintView: some View {
        if let hint = step.hint {
            if hintShown {
                HStack(alignment: .top, spacing: SvaraTheme.Spacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(SvaraTheme.Colors.points)
                    Text(hint)
                        .font(.svaraCallout)
                        .foregroundStyle(SvaraTheme.Colors.textSecondary)
                }
                .padding(SvaraTheme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SvaraTheme.Colors.points.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.sm, style: .continuous))
                .accessibilityLabel("Hint: \(hint)")
            } else {
                Button {
                    hintShown = true
                } label: {
                    Label(LearnCopy.tapToReveal, systemImage: "lightbulb")
                        .font(.svaraCallout.weight(.semibold))
                        .foregroundStyle(SvaraTheme.Colors.accent)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Reveals a gentle hint; it never affects your progress")
            }
        }
    }

    // MARK: Feedback banner (after checking an interactive step)

    @ViewBuilder
    private var feedbackBanner: some View {
        if hasChecked, step.isInteractive {
            HStack(spacing: SvaraTheme.Spacing.sm) {
                Image(systemName: lastAnswerMatched ? "checkmark.seal.fill" : "hand.wave.fill")
                    .foregroundStyle(lastAnswerMatched ? SvaraTheme.Colors.success : SvaraTheme.Colors.primary)
                Text(feedbackText)
                    .font(.svaraCallout.weight(.medium))
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)
                Spacer(minLength: 0)
            }
            .padding(SvaraTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background((lastAnswerMatched ? SvaraTheme.Colors.success : SvaraTheme.Colors.primary).opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.sm, style: .continuous))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(feedbackText)
        }
    }

    private var feedbackText: String {
        if lastAnswerMatched {
            return LearnCopy.affirmation(forIndex: index)
        } else {
            return LearnCopy.gentleCorrection(forAttempt: wrongAttempts - 1)
        }
    }

    // MARK: Action button

    @ViewBuilder
    private var actionButton: some View {
        if step.isInteractive && !hasChecked {
            PrimaryButton(title: "Check", isEnabled: hasAnswer) { check() }
        } else {
            PrimaryButton(title: isLastStep ? "Finish" : "Continue") { advance() }
        }
    }

    private var hasAnswer: Bool {
        switch step.kind {
        case .multipleChoice, .matchMeaning, .fillBlank:
            return selectedOption != nil
        case .syllableOrder:
            return builtSyllables.count == step.syllables.count
        default:
            return true
        }
    }

    private var currentAnswer: LessonAnswer {
        switch step.kind {
        case .multipleChoice, .matchMeaning, .fillBlank:
            return selectedOption.map { .option($0) } ?? .none
        case .syllableOrder:
            return .ordering(builtSyllables)
        default:
            return .none
        }
    }

    private func check() {
        let matched = LessonEvaluator.isCorrect(currentAnswer, for: step)
        lastAnswerMatched = matched
        if matched {
            correctCount += 1
        } else {
            wrongAttempts += 1
            // Surface the hint automatically on a near miss, gently.
            if step.hint != nil { hintShown = true }
        }
        withAnimation { hasChecked = true }
    }

    private func advance() {
        // Record this step (resume + hint tracking); never awards points.
        env.recordLessonStep(
            step,
            in: lesson,
            wasCorrect: step.isInteractive ? lastAnswerMatched : nil,
            hintUsed: hintShown
        )

        if isLastStep {
            env.completeLesson(lesson, correctCount: correctCount)
            withAnimation { finished = true }
        } else {
            withAnimation {
                index += 1
                selectedOption = nil
                hasChecked = false
                hintShown = false
                lastAnswerMatched = false
                wrongAttempts = 0
                syncSyllablePool()
            }
        }
    }
}

/// A simple wrapping row of tappable chips (for syllable ordering).
private struct FlowChips: View {
    let items: [String]
    var emptyHint: String = ""
    var filled: Bool = false
    let onTap: (String) -> Void

    var body: some View {
        if items.isEmpty {
            Text(emptyHint)
                .font(.svaraCallout)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 36)
        } else {
            // Enumerate so identical syllables (e.g. repeated sounds) stay unique.
            WrapHStack(items.indices.map { "\(items[$0])#\($0)" }) { tagged in
                let value = String(tagged.prefix(while: { $0 != "#" }))
                Button { onTap(value) } label: {
                    Text(value)
                        .font(.svaraHeadline)
                        .foregroundStyle(filled ? SvaraTheme.Colors.textOnPrimary : SvaraTheme.Colors.accent)
                        .padding(.horizontal, SvaraTheme.Spacing.lg)
                        .padding(.vertical, SvaraTheme.Spacing.sm)
                        .background(filled ? SvaraTheme.Colors.primary.opacity(0.85) : SvaraTheme.Colors.surface)
                        .clipShape(Capsule())
                        .overlay(Capsule().strokeBorder(SvaraTheme.Colors.accent.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(value)
            }
        }
    }
}

/// A minimal flow layout (iOS 16+ `Layout`) so chips wrap to multiple lines.
private struct WrapHStack<Content: View>: View {
    let tags: [String]
    let content: (String) -> Content

    init(_ tags: [String], @ViewBuilder content: @escaping (String) -> Content) {
        self.tags = tags
        self.content = content
    }

    var body: some View {
        FlowLayout(spacing: SvaraTheme.Spacing.sm) {
            ForEach(tags, id: \.self) { tag in
                content(tag)
            }
        }
    }
}

/// A small custom `Layout` that lays children left-to-right, wrapping rows.
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth, rowWidth > 0 {
                totalHeight += rowHeight + spacing
                totalWidth = max(totalWidth, rowWidth - spacing)
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight
        totalWidth = max(totalWidth, rowWidth - spacing)
        return CGSize(width: maxWidth == .infinity ? totalWidth : maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    LessonPlayerView(lesson: SeedContent.lessons[4]) // syllable-order lesson
        .environment(AppEnvironment.preview())
}
