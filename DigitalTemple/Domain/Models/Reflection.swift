import Foundation
import SwiftData

/// The quiet inner weather of a moment of return. Five honest options — no
/// judgement, no scoring.
enum Mood: String, Codable, CaseIterable, Identifiable {
    case quiet
    case grateful
    case hopeful
    case heavy
    case atPeace = "at_peace"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .quiet: return "Quiet"
        case .grateful: return "Grateful"
        case .hopeful: return "Hopeful"
        case .heavy: return "Heavy"
        case .atPeace: return "At peace"
        }
    }

    var glyph: String {
        switch self {
        case .quiet: return "🍃"
        case .grateful: return "🙏"
        case .hopeful: return "🌅"
        case .heavy: return "🌧️"
        case .atPeace: return "🪷"
        }
    }
}

/// A reflection written when the person returns to a sankalp.
@Model
final class Reflection {
    @Attribute(.unique) var id: UUID
    var sankalpId: UUID
    var content: String
    var mood: Mood
    var date: Date

    init(
        id: UUID = UUID(),
        sankalpId: UUID,
        content: String,
        mood: Mood,
        date: Date = Date()
    ) {
        self.id = id
        self.sankalpId = sankalpId
        self.content = content
        self.mood = mood
        self.date = date
    }
}
