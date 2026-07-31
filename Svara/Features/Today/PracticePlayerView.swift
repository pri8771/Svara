import SwiftUI

/// A guided, timed practice flow: intro → guidance steps with a breathing
/// ring → completion (awards points and updates the streak).
struct PracticePlayerView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss

    let practice: DailyPractice
    let mantra: Mantra?

    @State private var phase: Phase = .intro
    @State private var stepIndex = 0
    @State private var secondsRemaining: Int
    @State private var timer: Timer?
    @State private var elapsedSeconds = 0

    enum Phase { case intro, active, complete }

    init(practice: DailyPractice, mantra: Mantra?) {
        self.practice = practice
        self.mantra = mantra
        _secondsRemaining = State(initialValue: max(60, practice.durationMinutes * 60))
    }

    var body: some View {
        ZStack {
            SvaraTheme.Gradients.forTimeOfDay(practice.timeOfDay).ignoresSafeArea()
            content
                .padding(SvaraTheme.Spacing.screenMargin)
        }
        .onDisappear {
            timer?.invalidate()
            env.audioPlayback.stop()
        }
        .alert("Audio unavailable", isPresented: audioErrorIsPresented) {
            Button("OK", role: .cancel) { env.audioPlayback.clearPlaybackError() }
        } message: {
            Text(env.audioPlayback.playbackErrorMessage ?? "")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .intro: introView
        case .active: activeView
        case .complete: completeView
        }
    }

    // MARK: Intro

    private var introView: some View {
        VStack(alignment: .leading, spacing: SvaraTheme.Spacing.xl) {
            closeButton
            Spacer()
            Image(systemName: practice.systemImage)
                .font(.system(size: 60))
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: SvaraTheme.Spacing.sm) {
                Text(practice.title)
                    .font(.svaraDisplay)
                    .foregroundStyle(.white)
                Text(practice.subtitle)
                    .font(.svaraBody)
                    .foregroundStyle(.white.opacity(0.85))
            }
            if let mantra {
                Text(mantra.transliteration)
                    .font(.svaraSanskrit)
                    .italic()
                    .foregroundStyle(.white.opacity(0.95))
            }
            Spacer()
            PrimaryButton(title: "Begin", systemImage: "play.fill") { start() }
        }
    }

    // MARK: Active

    private var activeView: some View {
        VStack(spacing: SvaraTheme.Spacing.xl) {
            closeButton
            Spacer()
            ZStack {
                ProgressRing(progress: ringProgress, lineWidth: 12, tint: .white)
                    .frame(width: 220, height: 220)
                VStack(spacing: 4) {
                    Text(timeString)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("remaining")
                        .font(.svaraCaption)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            if !practice.guidance.isEmpty {
                Text(practice.guidance[min(stepIndex, practice.guidance.count - 1)])
                    .font(.svaraTitle)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
                    .id(stepIndex)
            }
            if let mantra, mantra.audioFileName != nil {
                audioButton(for: mantra)
            }
            Spacer()
            SecondaryButton(title: "Finish now") { complete() }
        }
    }

    // MARK: Complete

    private var completeView: some View {
        VStack(spacing: SvaraTheme.Spacing.xl) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundStyle(.white)
            VStack(spacing: SvaraTheme.Spacing.sm) {
                Text("Well done")
                    .font(.svaraDisplay)
                    .foregroundStyle(.white)
                Text("You earned +\(practice.points) Svara Points")
                    .font(.svaraHeadline)
                    .foregroundStyle(.white.opacity(0.9))
                Label("\(env.profile.currentStreak)-day streak", systemImage: "flame.fill")
                    .font(.svaraBody)
                    .foregroundStyle(.white)
                    .padding(.top, SvaraTheme.Spacing.sm)
            }
            Spacer()
            PrimaryButton(title: "Done") { dismiss() }
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
        }
    }

    /// Playback starts automatically with the practice; this control lets the
    /// user pause or resume it without presenting chanting as a separate mode.
    private func audioButton(for mantra: Mantra) -> some View {
        let isPlayingThis = env.audioPlayback.isPlaying && env.audioPlayback.currentFileName == mantra.audioFileName
        return Button {
            env.audioPlayback.toggle(fileName: mantra.audioFileName)
        } label: {
            Label(isPlayingThis ? "Pause audio" : "Play audio", systemImage: isPlayingThis ? "pause.circle.fill" : "play.circle.fill")
                .font(.svaraCallout.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, SvaraTheme.Spacing.md)
                .padding(.vertical, SvaraTheme.Spacing.sm)
                .background(.white.opacity(0.15))
                .clipShape(Capsule())
        }
        .accessibilityLabel(isPlayingThis ? "Pause practice audio" : "Play practice audio")
    }

    private var audioErrorIsPresented: Binding<Bool> {
        Binding(
            get: { env.audioPlayback.playbackErrorMessage != nil },
            set: { if !$0 { env.audioPlayback.clearPlaybackError() } }
        )
    }

    // MARK: Timing

    private var totalSeconds: Int { max(60, practice.durationMinutes * 60) }
    private var ringProgress: Double { 1 - Double(secondsRemaining) / Double(totalSeconds) }
    private var timeString: String {
        String(format: "%d:%02d", secondsRemaining / 60, secondsRemaining % 60)
    }

    private func start() {
        withAnimation { phase = .active }
        env.audioPlayback.play(fileName: mantra?.audioFileName, loops: true)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            tick()
        }
    }

    private func tick() {
        guard secondsRemaining > 0 else {
            complete()
            return
        }
        secondsRemaining -= 1
        elapsedSeconds += 1
        // Advance guidance steps evenly across the duration.
        if !practice.guidance.isEmpty {
            let interval = max(1, totalSeconds / practice.guidance.count)
            withAnimation { stepIndex = min(practice.guidance.count - 1, elapsedSeconds / interval) }
        }
    }

    private func complete() {
        timer?.invalidate()
        env.audioPlayback.stop()
        env.completePractice(practice, durationSeconds: max(1, elapsedSeconds))
        withAnimation { phase = .complete }
    }
}

#Preview {
    PracticePlayerView(
        practice: SeedContent.dailyPractices[0],
        mantra: SeedContent.mantras[0]
    )
    .environment(AppEnvironment.preview())
}
