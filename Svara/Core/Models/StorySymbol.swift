import Foundation

/// A short story or symbol exploring a deity and the human theme they embody
/// (courage, wisdom, devotion…). The heart of the Stories & Symbols tab.
struct StorySymbol: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let deity: String
    let theme: SpiritualTheme
    /// One-line hook.
    let summary: String
    /// The narrative itself.
    let story: String
    /// What the symbol / story teaches and how to apply it today.
    let symbolMeaning: String
    /// A short takeaway line for the reader to carry.
    let takeaway: String
    let readMinutes: Int
    let systemImage: String
    let isPremium: Bool

    // Provenance (optional; see ContentProvenanceCarrying).
    let sourceName: String?
    let sourceNote: String?
    /// e.g. "One way to understand this symbol… Traditions vary by region and family."
    let traditionNote: String?
    let reviewStatus: ContentReviewStatus?

    init(
        id: String,
        title: String,
        deity: String,
        theme: SpiritualTheme,
        summary: String,
        story: String,
        symbolMeaning: String,
        takeaway: String,
        readMinutes: Int = 4,
        systemImage: String = "sparkles",
        isPremium: Bool = false,
        sourceName: String? = nil,
        sourceNote: String? = nil,
        traditionNote: String? = nil,
        reviewStatus: ContentReviewStatus? = nil
    ) {
        self.id = id
        self.title = title
        self.deity = deity
        self.theme = theme
        self.summary = summary
        self.story = story
        self.symbolMeaning = symbolMeaning
        self.takeaway = takeaway
        self.readMinutes = readMinutes
        self.systemImage = systemImage
        self.isPremium = isPremium
        self.sourceName = sourceName
        self.sourceNote = sourceNote
        self.traditionNote = traditionNote
        self.reviewStatus = reviewStatus
    }
}

extension StorySymbol: ContentProvenanceCarrying {}
