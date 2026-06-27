import Foundation

/// A mantra or sloka with its Sanskrit text, transliteration, translation and
/// meaning. The atomic unit of devotional content in Svara.
struct Mantra: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    /// Devanagari text.
    let sanskrit: String
    /// Roman transliteration (IAST-style, simplified).
    let transliteration: String
    /// Plain-language English translation.
    let translation: String
    /// A short reflection on meaning and when to use it.
    let meaning: String
    let deity: String
    let theme: SpiritualTheme
    /// Suggested number of repetitions (japa).
    let repetitions: Int
    let durationMinutes: Int
    /// Optional bundled audio file name (without extension).
    let audioFileName: String?

    init(
        id: String,
        title: String,
        sanskrit: String,
        transliteration: String,
        translation: String,
        meaning: String,
        deity: String,
        theme: SpiritualTheme,
        repetitions: Int = 11,
        durationMinutes: Int = 3,
        audioFileName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.sanskrit = sanskrit
        self.transliteration = transliteration
        self.translation = translation
        self.meaning = meaning
        self.deity = deity
        self.theme = theme
        self.repetitions = repetitions
        self.durationMinutes = durationMinutes
        self.audioFileName = audioFileName
    }
}
