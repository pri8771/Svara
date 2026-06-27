import Foundation
import SwiftData

/// The eight sacred intentions a sankalp may hold. A sankalp is a vow made
/// before the divine — the spiritual heart of the app.
enum IntentionType: String, Codable, CaseIterable, Identifiable {
    case healing
    case gratitude
    case grief
    case renewal
    case protection
    case festivalObservance
    case personalVow
    case reconnection

    var id: String { rawValue }

    var title: String {
        switch self {
        case .healing: return "Healing"
        case .gratitude: return "Gratitude"
        case .grief: return "Grief"
        case .renewal: return "Renewal"
        case .protection: return "Protection"
        case .festivalObservance: return "Festival Observance"
        case .personalVow: return "Personal Vow"
        case .reconnection: return "Reconnection"
        }
    }

    /// A short, devotional framing shown when composing a sankalp.
    var prompt: String {
        switch self {
        case .healing: return "For the wellbeing of body, mind, or spirit."
        case .gratitude: return "In thanks for a grace already received."
        case .grief: return "Held in memory of one who has passed."
        case .renewal: return "For a fresh beginning or a turning point."
        case .protection: return "Asking for shelter and strength."
        case .festivalObservance: return "To honour a sacred occasion."
        case .personalVow: return "A promise kept between you and the divine."
        case .reconnection: return "To return to a thread that was loosened."
        }
    }

    var glyph: String {
        switch self {
        case .healing: return "🌿"
        case .gratitude: return "🙏"
        case .grief: return "🕯️"
        case .renewal: return "🌅"
        case .protection: return "🛡️"
        case .festivalObservance: return "🪔"
        case .personalVow: return "📿"
        case .reconnection: return "🪷"
        }
    }
}

/// The living state of a sankalp. It is never "deleted" — once made, a vow is
/// either active, fulfilled, preserved as remembrance, or quietly dormant.
enum SankalpStatus: String, Codable, CaseIterable {
    case active
    case fulfilled
    case preserved
    case dormant

    var title: String {
        switch self {
        case .active: return "Active"
        case .fulfilled: return "Fulfilled"
        case .preserved: return "Preserved"
        case .dormant: return "Resting"
        }
    }
}

@Model
final class Sankalp {
    @Attribute(.unique) var id: UUID
    var intention: String
    /// Optional dedication — for whom the vow is held.
    var forWhom: String?
    var intentionType: IntentionType
    /// The devata before whom the sankalp is made, if any.
    var devataId: UUID?
    var startDate: Date
    var dueDate: Date?
    var status: SankalpStatus
    var mandirId: UUID

    init(
        id: UUID = UUID(),
        intention: String,
        forWhom: String? = nil,
        intentionType: IntentionType,
        devataId: UUID? = nil,
        startDate: Date = Date(),
        dueDate: Date? = nil,
        status: SankalpStatus = .active,
        mandirId: UUID
    ) {
        self.id = id
        self.intention = intention
        self.forWhom = forWhom
        self.intentionType = intentionType
        self.devataId = devataId
        self.startDate = startDate
        self.dueDate = dueDate
        self.status = status
        self.mandirId = mandirId
    }
}
