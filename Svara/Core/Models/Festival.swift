import Foundation

/// An upcoming festival moment with its story, significance and simple
/// activities a young person can do to mark the day.
struct Festival: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    /// Date of the festival (year is illustrative for the seed catalogue).
    let date: Date
    let deity: String?
    let tagline: String
    /// The "why" — significance in plain, modern language.
    let significance: String
    /// The story behind the festival.
    let story: String
    /// Small, doable activities to mark the moment.
    let activities: [String]
    let theme: SpiritualTheme
    let systemImage: String

    // Provenance (optional; see ContentProvenanceCarrying).
    let sourceName: String?
    let sourceNote: String?
    /// Acknowledges that dates and customs vary by region/calendar.
    let traditionNote: String?
    let reviewStatus: ContentReviewStatus?

    init(
        id: String,
        name: String,
        date: Date,
        deity: String? = nil,
        tagline: String,
        significance: String,
        story: String,
        activities: [String],
        theme: SpiritualTheme,
        systemImage: String = "sparkles",
        sourceName: String? = nil,
        sourceNote: String? = nil,
        traditionNote: String? = nil,
        reviewStatus: ContentReviewStatus? = nil
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.deity = deity
        self.tagline = tagline
        self.significance = significance
        self.story = story
        self.activities = activities
        self.theme = theme
        self.systemImage = systemImage
        self.sourceName = sourceName
        self.sourceNote = sourceNote
        self.traditionNote = traditionNote
        self.reviewStatus = reviewStatus
    }

    // ContentProvenanceCarrying conformance is declared below.

    /// Whole days from `reference` until the festival (negative if past).
    func daysUntil(from reference: Date = Date()) -> Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: reference)
        let target = cal.startOfDay(for: date)
        return cal.dateComponents([.day], from: start, to: target).day ?? 0
    }
}

extension Festival: ContentProvenanceCarrying {}
