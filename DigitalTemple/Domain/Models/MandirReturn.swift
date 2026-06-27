import Foundation
import SwiftData

/// The kinds of private offering a person may place before their altar. Each is
/// a small, wordless act of devotion — flower, water, lamp, or a spoken vow.
enum OfferingKind: String, Codable, CaseIterable, Identifiable {
    case pushpa   // a flower
    case jal      // water
    case deep     // a lamp / light
    case vachan   // a word, a vow spoken

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pushpa: return "Pushpa"
        case .jal: return "Jal"
        case .deep: return "Deep"
        case .vachan: return "Vachan"
        }
    }

    var subtitle: String {
        switch self {
        case .pushpa: return "A flower"
        case .jal: return "Water"
        case .deep: return "A lamp"
        case .vachan: return "A spoken word"
        }
    }

    var glyph: String {
        switch self {
        case .pushpa: return "🌼"
        case .jal: return "💧"
        case .deep: return "🪔"
        case .vachan: return "📜"
        }
    }
}

/// A single act of returning to the mandir — the atomic unit of the sacred
/// relationship over time. A return may be simply lighting the lamp (presence),
/// placing an offering, or leaving a reflection. Woven together, these returns
/// are the **Thread**.
@Model
final class MandirReturn {
    @Attribute(.unique) var id: UUID
    var mandirId: UUID
    /// The sankalp held during this return, if any.
    var sankalpId: UUID?
    /// The offering placed, if this return was an offering.
    var offeringKind: OfferingKind?
    /// The reflection left, if this return was a reflection.
    var reflectionId: UUID?
    var note: String?
    var date: Date

    init(
        id: UUID = UUID(),
        mandirId: UUID,
        sankalpId: UUID? = nil,
        offeringKind: OfferingKind? = nil,
        reflectionId: UUID? = nil,
        note: String? = nil,
        date: Date = Date()
    ) {
        self.id = id
        self.mandirId = mandirId
        self.sankalpId = sankalpId
        self.offeringKind = offeringKind
        self.reflectionId = reflectionId
        self.note = note
        self.date = date
    }

    /// How this return reads in the Thread.
    enum Kind { case lamp, offering, reflection }

    var kind: Kind {
        if offeringKind != nil { return .offering }
        if reflectionId != nil { return .reflection }
        return .lamp
    }
}
