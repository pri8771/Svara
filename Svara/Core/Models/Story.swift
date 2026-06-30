import SwiftUI

/// A human-theme lens for the Stories & Symbols library.
enum StoryTheme: String, Codable, CaseIterable, Identifiable, Hashable {
    case courage      = "Courage"
    case wisdom       = "Wisdom"
    case abundance    = "Abundance"
    case stillness    = "Stillness"
    case beginnings   = "Beginnings"
    case devotion     = "Devotion"
    case strength     = "Strength"

    var id: String { rawValue }
    var label: String { rawValue }

    var systemImage: String {
        switch self {
        case .courage: return "flame.fill"
        case .wisdom: return "brain.head.profile"
        case .abundance: return "leaf.fill"
        case .stillness: return "moon.stars.fill"
        case .beginnings: return "sparkles"
        case .devotion: return "heart.circle.fill"
        case .strength: return "shield.fill"
        }
    }

    var colorHex: String {
        switch self {
        case .courage: return "#E07F1C"
        case .wisdom: return "#6C8FD6"
        case .abundance: return "#7FA98C"
        case .stillness: return "#4B4699"
        case .beginnings: return "#F5A23B"
        case .devotion: return "#E0729A"
        case .strength: return "#322E6E"
        }
    }

    var color: Color { Color(hex: colorHex) }
}

/// A story or myth about a deity, explored through a human theme — the core unit
/// of the production Stories & Symbols tab.
///
/// This is a richer, Phase 2D model that lives alongside the original
/// `StorySymbol` (which still backs validation/seed tests). Content loads from
/// `seed_story_library.json` via `StoriesService`.
///
/// Firebase mapping (future): collection `stories`, document id = `id`. Note:
/// user reflections (`ReflectionEntry`) are **never** synced — see `ReflectionStore`.
struct Story: Identifiable, Codable, Hashable {
    let id: String
    let deity: String
    let title: String
    let theme: StoryTheme
    /// Estimated read time (3–8 minutes).
    let durationMinutes: Int
    /// The story text in light markdown (~300–600 words).
    let bodyMarkdown: String
    /// A humble, 1–3 sentence reading of the story's meaning.
    let moralOrMeaning: String
    /// 2–4 symbols mentioned in the story.
    let symbolism: [SymbolEntry]
    /// An open-ended, personal reflection prompt.
    let reflectionPrompt: String
    /// Optional link to an Aaroh lesson ("practice this mantra").
    let relatedMantraId: String?
    /// Optional link to a festival.
    let relatedFestivalId: String?
    /// Always present: acknowledges variation across traditions.
    let traditionNote: String
    let sourceName: String
    let sourceNote: String
    /// "draft" | "reviewed".
    let reviewStatus: String
    let region: [String]
    let tags: [String]

    var durationLabel: String { "\(durationMinutes) min read" }

    /// Lowercased haystack for search (title, deity, tags, theme).
    var searchHaystack: String {
        ([title, deity, theme.label] + tags).joined(separator: " ").lowercased()
    }

    func matches(search query: String) -> Bool {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return true }
        return searchHaystack.contains(q)
    }
}
