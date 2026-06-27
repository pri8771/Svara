import Foundation

/// A short shloka surfaced once per day ("shloka of the day"). Lighter than a
/// full `Mantra`: a single verse with transliteration, translation and a brief
/// meaning, plus a deep link to somewhere relevant in the app.
///
/// Firebase mapping (future): collection `shlokasOfDay`, document id = `id`.
/// `dateKey` (optional "MM-dd") can pin a shloka to a calendar day; when nil,
/// selection is deterministic-by-day via `ShlokaSelector`.
struct ShlokaOfDay: Identifiable, Codable, Hashable {
    let id: String
    /// Devanagari text. Optional — some entries are transliteration-only.
    let sanskritText: String?
    let transliteration: String
    let translation: String
    let meaning: String
    let theme: SpiritualTheme
    /// Human-readable source (e.g. "Bhagavad Gita 2.47"). Optional.
    let sourceName: String?
    /// A short editorial note about the source/translation choice. Optional.
    let sourceNote: String?
    /// Acknowledges regional/family variation. Optional.
    let traditionNote: String?
    let reviewStatus: ContentReviewStatus?
    /// Optional fixed day assignment in "MM-dd" form.
    let dateKey: String?
    /// Where tapping the shloka should take the user. See `AppDeepLink`.
    let deepLinkTarget: String

    init(
        id: String,
        sanskritText: String? = nil,
        transliteration: String,
        translation: String,
        meaning: String,
        theme: SpiritualTheme,
        sourceName: String? = nil,
        sourceNote: String? = nil,
        traditionNote: String? = nil,
        reviewStatus: ContentReviewStatus? = nil,
        dateKey: String? = nil,
        deepLinkTarget: String = AppDeepLink.today.rawValue
    ) {
        self.id = id
        self.sanskritText = sanskritText
        self.transliteration = transliteration
        self.translation = translation
        self.meaning = meaning
        self.theme = theme
        self.sourceName = sourceName
        self.sourceNote = sourceNote
        self.traditionNote = traditionNote
        self.reviewStatus = reviewStatus
        self.dateKey = dateKey
        self.deepLinkTarget = deepLinkTarget
    }

    // MARK: - Widget-ready display text
    //
    // Provided now so a future Home Screen / Lock Screen widget can render a
    // shloka without any model changes.

    /// One short line, safe for the smallest widget. Falls back gracefully.
    var shortDisplayText: String {
        translation.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Two–three lines for a medium widget: transliteration + translation.
    var mediumDisplayText: String {
        let line1 = transliteration.trimmingCharacters(in: .whitespacesAndNewlines)
        let line2 = translation.trimmingCharacters(in: .whitespacesAndNewlines)
        return line1.isEmpty ? line2 : "\(line1)\n\(line2)"
    }
}

extension ShlokaOfDay: ContentProvenanceCarrying {}

/// Lightweight, string-encoded deep links used by content (e.g. shlokas) to
/// point at a destination. Stored as a plain string for easy JSON/Firebase
/// authoring; parsed into a `Destination` for routing.
enum AppDeepLink: String {
    case today
    case learn
    case festivals
    case stories
    case profile

    /// Routable destination parsed from a `deepLinkTarget` string.
    /// Supports plain tabs ("today") and `type:id` forms
    /// ("mantra:mantra.gayatri", "lesson:lesson.gayatri.basics",
    /// "story:story.hanuman.courage", "festival:festival.diwali").
    enum Destination: Equatable {
        case tab(AppDeepLink)
        case mantra(String)
        case lesson(String)
        case story(String)
        case festival(String)
        case unknown(String)
    }

    static func parse(_ raw: String) -> Destination {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if let tab = AppDeepLink(rawValue: trimmed) {
            return .tab(tab)
        }
        let parts = trimmed.split(separator: ":", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return .unknown(trimmed) }
        let (kind, value) = (parts[0], parts[1])
        switch kind {
        case "mantra": return .mantra(value)
        case "lesson": return .lesson(value)
        case "story": return .story(value)
        case "festival": return .festival(value)
        case "tab":
            if let tab = AppDeepLink(rawValue: value) { return .tab(tab) }
            return .unknown(trimmed)
        default: return .unknown(trimmed)
        }
    }
}
