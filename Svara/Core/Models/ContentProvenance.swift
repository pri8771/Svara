import Foundation

/// Editorial review state for a piece of devotional content. Supports the
/// content-sensitivity guardrails: nothing should ship to users as fact without
/// human review, and we want to track provenance explicitly.
///
/// Firebase mapping (future): stored as a string field `reviewStatus`.
enum ContentReviewStatus: String, Codable, Hashable, CaseIterable {
    /// Drafted, not yet reviewed.
    case draft
    /// Generated/assembled by automation, pending human review.
    case aiDrafted
    /// Reviewed and approved by a human editor.
    case humanReviewed
    /// Reviewed and traced to a cited source.
    case sourced

    var isReviewed: Bool { self == .humanReviewed || self == .sourced }
}

/// Provenance fields shared (by convention) across devotional content models:
/// `sourceName`, `sourceNote`, `traditionNote`, `reviewStatus`. Each model
/// declares these as optionals so JSON authoring stays light and older content
/// keeps decoding.
///
/// Copy guidance (see ProductGuardrails §7): when presenting symbolic or
/// interpretive meaning, prefer humble, plural phrasing such as
/// "One common translation…", "One way to understand this symbol…",
/// "Traditions vary by region and family…".
protocol ContentProvenanceCarrying {
    /// Human-readable source, e.g. "Bhagavad Gita 2.47".
    var sourceName: String? { get }
    /// A short editorial note about the source or translation choice.
    var sourceNote: String? { get }
    /// A note acknowledging regional/family variation.
    var traditionNote: String? { get }
    /// Editorial review state.
    var reviewStatus: ContentReviewStatus? { get }
}
