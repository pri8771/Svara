import AVFoundation
import Foundation

/// Plays a mantra's bundled audio clip (chant/recitation) so learners can
/// listen along during practice and lessons.
///
/// A single shared instance lives on `AppEnvironment` so starting playback in
/// one screen (e.g. the practice player) stops anything playing elsewhere,
/// and so views can simply observe `isPlaying` / `currentFileName` to reflect
/// state in their play/pause controls.
@Observable
@MainActor
final class AudioPlaybackService: NSObject {
    private(set) var isPlaying = false
    /// The `audioFileName` (without extension) currently loaded, if any.
    private(set) var currentFileName: String?
    /// User-safe failure copy so a missing or undecodable asset never fails silently.
    private(set) var playbackErrorMessage: String?

    @ObservationIgnored private var player: AVAudioPlayer?
    @ObservationIgnored private var observers: [NSObjectProtocol] = []
    @ObservationIgnored private var shouldResumeAfterInterruption = false

    override init() {
        super.init()
        let center = NotificationCenter.default
        observers.append(center.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in self?.handleInterruption(notification) }
        })
        observers.append(center.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in self?.handleRouteChange(notification) }
        })
        observers.append(center.addObserver(
            forName: AVAudioSession.mediaServicesWereResetNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.stop() }
        })
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    /// Toggles playback of `fileName` (as stored on `Mantra.audioFileName`):
    /// starts it if nothing is playing (or a different clip is loaded), pauses
    /// it if it's already playing, and resumes if it's paused.
    func toggle(fileName: String?) {
        guard let fileName else { return }

        if currentFileName == fileName, let player {
            if isPlaying {
                player.pause()
                isPlaying = false
            } else {
                do {
                    try activateSession()
                    guard player.play() else { throw PlaybackFailure.couldNotStart }
                    playbackErrorMessage = nil
                    isPlaying = true
                } catch {
                    failPlayback()
                }
            }
            return
        }

        play(fileName: fileName)
    }

    /// Starts (or restarts) playback of `fileName` from the beginning.
    func play(fileName: String?, loops: Bool = false) {
        guard let fileName else { return }
        guard let url = resourceURL(for: fileName) else {
            failPlayback()
            return
        }

        do {
            try activateSession()
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.delegate = self
            newPlayer.numberOfLoops = loops ? -1 : 0
            newPlayer.volume = 1
            guard newPlayer.prepareToPlay() else { throw PlaybackFailure.couldNotPrepare }
            player = newPlayer
            currentFileName = fileName
            guard newPlayer.play() else { throw PlaybackFailure.couldNotStart }
            playbackErrorMessage = nil
            isPlaying = true
        } catch {
            failPlayback()
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func stop() {
        resetPlayback()
        playbackErrorMessage = nil
    }

    func clearPlaybackError() {
        playbackErrorMessage = nil
    }

    private func resourceURL(for fileName: String) -> URL? {
        // M4A/AAC is the canonical shipping format. MP3 remains a fallback for
        // future reviewed content so the model's extension-free field is stable.
        ["m4a", "mp3"].lazy.compactMap {
            Bundle.main.url(forResource: fileName, withExtension: $0)
        }.first
    }

    private func failPlayback() {
        resetPlayback()
        playbackErrorMessage = "This recording couldn't be played. Please try again."
    }

    private func resetPlayback() {
        player?.stop()
        player = nil
        currentFileName = nil
        isPlaying = false
        deactivateSession()
    }

    private func activateSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)
    }

    private func deactivateSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func handleInterruption(_ notification: Notification) {
        guard let rawType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: rawType) else { return }
        switch type {
        case .began:
            shouldResumeAfterInterruption = isPlaying
            player?.pause()
            isPlaying = false
        case .ended:
            let rawOptions = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            let options = AVAudioSession.InterruptionOptions(rawValue: rawOptions)
            if shouldResumeAfterInterruption, options.contains(.shouldResume), player != nil {
                do {
                    try activateSession()
                    guard player?.play() == true else { throw PlaybackFailure.couldNotStart }
                    isPlaying = true
                } catch {
                    failPlayback()
                }
            }
            shouldResumeAfterInterruption = false
        @unknown default:
            pause()
        }
    }

    private func handleRouteChange(_ notification: Notification) {
        guard let rawReason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
              AVAudioSession.RouteChangeReason(rawValue: rawReason) == .oldDeviceUnavailable else { return }
        // Avoid unexpectedly moving a chant from disconnected headphones to
        // the speaker. The user can explicitly resume from the visible control.
        pause()
    }
}

private enum PlaybackFailure: Error {
    case couldNotPrepare
    case couldNotStart
}

extension AudioPlaybackService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            guard self.player === player else { return }
            self.stop()
        }
    }
}
