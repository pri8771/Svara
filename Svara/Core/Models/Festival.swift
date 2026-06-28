import Foundation

/// A symbol associated with a festival (e.g. a lamp, colour, thread) and what it
/// commonly means. Presented with humble framing — meanings vary by tradition.
struct FestivalSymbol: Codable, Hashable, Identifiable {
    var id: String { name }
    let name: String
    let meaning: String
}

/// A tiny, doable 2–5 minute activity for a festival: a few gentle steps and an
/// optional reflection. **Not** a ritual simulation — these are real-world,
/// reflective, "try it in your own way" prompts.
///
/// Firebase mapping (future): embedded in the festival document.
struct FestivalActivity: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    /// Estimated time to complete (2–5 minutes).
    let durationMinutes: Int
    /// Gentle steps to move through.
    let steps: [String]
    /// An optional reflection prompt shown at the end. Any text the user writes
    /// stays **local-only** and is never persisted remotely.
    let reflectionPrompt: String?
    /// Svara Points awarded once on completion.
    let points: Int

    init(
        id: String,
        title: String,
        durationMinutes: Int = 3,
        steps: [String],
        reflectionPrompt: String? = nil,
        points: Int = 15
    ) {
        self.id = id
        self.title = title
        self.durationMinutes = durationMinutes
        self.steps = steps
        self.reflectionPrompt = reflectionPrompt
        self.points = points
    }
}

/// An upcoming festival moment with its story, significance and simple
/// activities a young person can do to mark the day.
///
/// Phase 2C: festivals carry richer, seasonal content — a `shortDescription`
/// for cards, `whyItMatters`, `symbols`, a `familyPrompt`, `regionTags`, a
/// guided `tinyActivity`, and optional links to a related mantra/practice. All
/// new fields are optional/defaulted so older JSON keeps decoding unchanged.
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

    // MARK: Phase 2C enrichment (all optional / defaulted)

    /// A short, card-friendly line of context.
    let shortDescription: String?
    /// A personal "why does this matter to me" framing.
    let whyItMatters: String?
    /// Symbols and their commonly-understood meanings.
    let symbols: [FestivalSymbol]
    /// A gentle family-conversation prompt.
    let familyPrompt: String?
    /// Regions this festival is especially associated with (see `FestivalRegion`).
    let regionTags: [String]
    /// A related practice id (Today tab), if any.
    let relatedPracticeID: String?
    /// A related mantra id, if any.
    let relatedMantraID: String?
    /// A guided 2–5 minute activity.
    let tinyActivity: FestivalActivity?
    /// Whether the date is approximate (dates vary by region/calendar).
    let isDateApproximate: Bool

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
        shortDescription: String? = nil,
        whyItMatters: String? = nil,
        symbols: [FestivalSymbol] = [],
        familyPrompt: String? = nil,
        regionTags: [String] = [],
        relatedPracticeID: String? = nil,
        relatedMantraID: String? = nil,
        tinyActivity: FestivalActivity? = nil,
        isDateApproximate: Bool = false,
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
        self.shortDescription = shortDescription
        self.whyItMatters = whyItMatters
        self.symbols = symbols
        self.familyPrompt = familyPrompt
        self.regionTags = regionTags
        self.relatedPracticeID = relatedPracticeID
        self.relatedMantraID = relatedMantraID
        self.tinyActivity = tinyActivity
        self.isDateApproximate = isDateApproximate
        self.sourceName = sourceName
        self.sourceNote = sourceNote
        self.traditionNote = traditionNote
        self.reviewStatus = reviewStatus
    }

    // Custom decoding so older/lean JSON may omit the newer fields.
    enum CodingKeys: String, CodingKey {
        case id, name, date, deity, tagline, significance, story, activities, theme, systemImage
        case shortDescription, whyItMatters, symbols, familyPrompt, regionTags
        case relatedPracticeID, relatedMantraID, tinyActivity, isDateApproximate
        case sourceName, sourceNote, traditionNote, reviewStatus
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        date = try c.decode(Date.self, forKey: .date)
        deity = try c.decodeIfPresent(String.self, forKey: .deity)
        tagline = try c.decode(String.self, forKey: .tagline)
        significance = try c.decode(String.self, forKey: .significance)
        story = try c.decode(String.self, forKey: .story)
        activities = try c.decodeIfPresent([String].self, forKey: .activities) ?? []
        theme = try c.decode(SpiritualTheme.self, forKey: .theme)
        systemImage = try c.decodeIfPresent(String.self, forKey: .systemImage) ?? "sparkles"
        shortDescription = try c.decodeIfPresent(String.self, forKey: .shortDescription)
        whyItMatters = try c.decodeIfPresent(String.self, forKey: .whyItMatters)
        symbols = try c.decodeIfPresent([FestivalSymbol].self, forKey: .symbols) ?? []
        familyPrompt = try c.decodeIfPresent(String.self, forKey: .familyPrompt)
        regionTags = try c.decodeIfPresent([String].self, forKey: .regionTags) ?? []
        relatedPracticeID = try c.decodeIfPresent(String.self, forKey: .relatedPracticeID)
        relatedMantraID = try c.decodeIfPresent(String.self, forKey: .relatedMantraID)
        tinyActivity = try c.decodeIfPresent(FestivalActivity.self, forKey: .tinyActivity)
        isDateApproximate = try c.decodeIfPresent(Bool.self, forKey: .isDateApproximate) ?? false
        sourceName = try c.decodeIfPresent(String.self, forKey: .sourceName)
        sourceNote = try c.decodeIfPresent(String.self, forKey: .sourceNote)
        traditionNote = try c.decodeIfPresent(String.self, forKey: .traditionNote)
        reviewStatus = try c.decodeIfPresent(ContentReviewStatus.self, forKey: .reviewStatus)
    }

    // MARK: Display helpers

    /// Short context for cards; falls back to the tagline.
    var shortContext: String { shortDescription ?? tagline }
    /// "Why it matters" text; falls back to significance.
    var whyItMattersText: String { whyItMatters ?? significance }

    /// Whole days from `reference` until the festival (negative if past).
    func daysUntil(from reference: Date = Date()) -> Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: reference)
        let target = cal.startOfDay(for: date)
        return cal.dateComponents([.day], from: start, to: target).day ?? 0
    }

    /// Whether the festival is today or still ahead, relative to `reference`.
    func isUpcoming(from reference: Date = Date()) -> Bool { daysUntil(from: reference) >= 0 }
}

extension Festival: ContentProvenanceCarrying {}
