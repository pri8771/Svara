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

    @ObservationIgnored private var player: AVAudioPlayer?

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
                activateSession()
                player.play()
                isPlaying = true
            }
            return
        }

        play(fileName: fileName)
    }

    /// Starts (or restarts) playback of `fileName` from the beginning.
    func play(fileName: String?, loops: Bool = false) {
        guard let fileName else { return }
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            stop()
            return
        }

        do {
            activateSession()
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.delegate = self
            newPlayer.numberOfLoops = loops ? -1 : 0
            newPlayer.prepareToPlay()
            player = newPlayer
            currentFileName = fileName
            newPlayer.play()
            isPlaying = true
        } catch {
            stop()
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func stop() {
        player?.stop()
        player = nil
        currentFileName = nil
        isPlaying = false
        deactivateSession()
    }

    private func activateSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    private func deactivateSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

extension AudioPlaybackService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            guard self.player === player else { return }
            self.stop()
        }
    }
}
