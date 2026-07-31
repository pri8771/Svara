import AVFoundation
import XCTest
@testable import Svara

final class AudioAssetTests: XCTestCase {
    func testEveryAuthoredRecordingIsBundledAndDecodable() throws {
        let provider = SeedContentProvider(bundle: .main)
        let fileNames = Set(provider.mantras.compactMap(\.audioFileName))

        XCTAssertFalse(fileNames.isEmpty, "The shipped mantra catalogue should reference recordings")

        for fileName in fileNames.sorted() {
            let url = ["m4a", "mp3"].lazy.compactMap {
                Bundle.main.url(forResource: fileName, withExtension: $0)
            }.first
            let recordingURL = try XCTUnwrap(url, "Missing bundled recording for \(fileName)")
            let player = try AVAudioPlayer(contentsOf: recordingURL)

            XCTAssertGreaterThan(player.duration, 0, "\(fileName) must have audible duration")
            XCTAssertTrue(player.prepareToPlay(), "\(fileName) must decode through Apple's audio stack")
        }
    }
}
