import SwiftUI

/// A gentle, guided 2–5 minute festival activity: intro → a few steps → an
/// optional reflection → completion (awards points once). Reflection text stays
/// **local-only** and is never stored or sent anywhere.
///
/// This is reflective, not a ritual simulation — there is nothing to tap-to-ring
/// or perform on screen.
struct FestivalActivityView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss

    let festival: Festival

    @State private var phase: Phase = .intro
    @State private var stepIndex = 0
    @State private var reflectionText = ""

    enum Phase { case intro, steps, reflection, complete }

    private var activity: FestivalActivity? { festival.tinyActivity }

    var body: some View {
        ZStack {
            SvaraTheme.Gradients.dusk.ignoresSafeArea()
            Group {
                if let activity {
                    content(activity)
                } else {
                    missing
                }
            }
            .padding(SvaraTheme.Spacing.screenMargin)
        }
    }

    @ViewBuilder
    private func content(_ activity: FestivalActivity) -> some View {
        switch phase {
        case .intro: introView(activity)
        case .steps: stepsView(activity)
        case .reflection: reflectionView(activity)
        case .complete: completeView(activity)
        }
    }

    // MARK: Intro

    private func introView(_ activity: FestivalActivity) -> some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xl) {
            closeButton
            Spacer()
            Image(systemName: festival.systemImage)
                .font(.system(size: 56))
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
                Text(activity.title)
                    .font(.svaraDisplay)
                    .foregroundStyle(.white)
                Label("\(activity.durationMinutes) min · try it in your own way", systemImage: "leaf.fill")
                    .font(.svaraBody)
                    .foregroundStyle(.white.opacity(0.85))
            }
            Spacer()
            PrimaryButton(title: "Begin", systemImage: "play.fill") {
                withAnimation { phase = .steps }
            }
        }
    }

    // MARK: Steps

    private func stepsView(_ activity: FestivalActivity) -> some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xl) {
            HStack(spacing: SvaraTheme.Spacing.md) {
                closeButton
                ProgressView(value: Double(stepIndex + 1), total: Double(max(1, activity.steps.count)))
                    .tint(.white)
                    .accessibilityLabel("Step \(stepIndex + 1) of \(activity.steps.count)")
            }
            Spacer()
            Text("Step \(stepIndex + 1) of \(activity.steps.count)")
                .svaraEyebrow()
                .foregroundStyle(.white.opacity(0.8))
            Text(activity.steps[min(stepIndex, activity.steps.count - 1)])
                .font(.svaraTitle)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .id(stepIndex)
                .transition(.opacity)
            Spacer()
            PrimaryButton(title: isLastStep(activity) ? "Next" : "Continue") {
                withAnimation {
                    if isLastStep(activity) {
                        phase = activity.reflectionPrompt == nil ? .complete : .reflection
                        if phase == .complete { award() }
                    } else {
                        stepIndex += 1
                    }
                }
            }
        }
    }

    private func isLastStep(_ activity: FestivalActivity) -> Bool {
        stepIndex >= activity.steps.count - 1
    }

    // MARK: Reflection (local-only)

    private func reflectionView(_ activity: FestivalActivity) -> some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.lg) {
            closeButton
            Spacer()
            Text("A moment to reflect").svaraEyebrow().foregroundStyle(.white.opacity(0.8))
            Text(activity.reflectionPrompt ?? "")
                .font(.svaraTitle)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            TextEditor(text: $reflectionText)
                .frame(height: 120)
                .scrollContentBackground(.hidden)
                .padding(SvaraTheme.Spacing.md)
                .background(.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.md, style: .continuous))
                .foregroundStyle(.white)
                .accessibilityLabel("Your reflection, kept private on this device")
            Text("Kept private on your device.")
                .font(.svaraCaption)
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            PrimaryButton(title: "Complete") {
                withAnimation { phase = .complete }
                award()
            }
        }
    }

    // MARK: Complete

    private func completeView(_ activity: FestivalActivity) -> some View {
        VStack(spacing: SvaraTheme.Spacing.xl) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundStyle(.white)
            VStack(spacing: SvaraTheme.Spacing.sm) {
                Text("You marked the moment")
                    .font(.svaraDisplay)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                Text("+\(activity.points) Svara Points")
                    .font(.svaraHeadline)
                    .foregroundStyle(.white.opacity(0.9))
                Text("A tiny way to connect, in your own way.")
                    .font(.svaraCallout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            PrimaryButton(title: "Done") { dismiss() }
        }
    }

    private var missing: some View {
        VStack(spacing: SvaraTheme.Spacing.lg) {
            closeButton
            Spacer()
            Text("This moment has no activity yet.")
                .font(.svaraTitle)
                .foregroundStyle(.white)
            Spacer()
        }
    }

    private var closeButton: some View {
        HStack {
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .accessibilityLabel("Close activity")
        }
    }

    /// Awards points exactly once via the unified, deduped progress rules.
    private func award() {
        env.completeFestivalActivity(festival)
    }
}

#Preview {
    FestivalActivityView(festival: SeedContent.festivals[5])
        .environment(AppEnvironment.preview())
}
