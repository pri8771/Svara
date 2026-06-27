import Foundation
import SwiftData

/// What a memory holds. Memories are the long thread of a mandir — the things
/// a person wants to remember and preserve.
enum MemoryType: String, Codable, CaseIterable, Identifiable {
    case reflection
    case moment
    case tradition
    case offering

    var id: String { rawValue }

    var title: String {
        switch self {
        case .reflection: return "Reflection"
        case .moment: return "Moment"
        case .tradition: return "Tradition"
        case .offering: return "Offering"
        }
    }

    var glyph: String {
        switch self {
        case .reflection: return "🪔"
        case .moment: return "🌸"
        case .tradition: return "🧎"
        case .offering: return "🍚"
        }
    }
}

/// A preserved memory belonging to the mandir.
@Model
final class Memory {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var date: Date
    var type: MemoryType
    var mandirId: UUID

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        date: Date = Date(),
        type: MemoryType,
        mandirId: UUID
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.type = type
        self.mandirId = mandirId
    }
}
