import Foundation

/// A gentle once-a-day check-in: an optional mood, an optional one-line
/// intention, and an optional note. Foundation for a future "how are you
/// arriving today?" moment on the Today screen. Intentionally low-pressure —
/// every field is optional and skipping is always fine.
///
/// PRIVACY (Phase 2A): private reflection text — `intention` and `note` — is
/// **local-only**. It must NOT be synced to Firestore in Phase 2A. When cloud
/// sync arrives, only non-sensitive aggregates (e.g. `mood`, that a check-in
/// happened, `dateKey`) may sync, and only with explicit user consent;
/// reflection body text stays on device unless the user opts in.
///
/// Firebase mapping (future): subcollection `users/{uid}/checkIns`,
/// document id = `dateKey` (one check-in per day) — excluding `intention`/`note`.
struct DailyCheckIn: Identifiable, Codable, Hashable {
    /// Stable per-day identity.
    var id: String { dateKey }
    /// "yyyy-MM-dd" for the day this check-in belongs to.
    let dateKey: String
    var mood: Mood?
    var intention: String?
    var note: String?
    var createdAt: Date

    enum Mood: String, Codable, CaseIterable, Identifiable, Hashable {
        case calm
        case grateful
        case joyful
        case reflective
        case tired
        case anxious

        var id: String { rawValue }

        var label: String {
            switch self {
            case .calm: return "Calm"
            case .grateful: return "Grateful"
            case .joyful: return "Joyful"
            case .reflective: return "Reflective"
            case .tired: return "Tired"
            case .anxious: return "Anxious"
            }
        }

        var systemImage: String {
            switch self {
            case .calm: return "leaf.fill"
            case .grateful: return "hands.sparkles.fill"
            case .joyful: return "sun.max.fill"
            case .reflective: return "moon.stars.fill"
            case .tired: return "cloud.fill"
            case .anxious: return "wind"
            }
        }
    }

    init(
        dateKey: String,
        mood: Mood? = nil,
        intention: String? = nil,
        note: String? = nil,
        createdAt: Date = Date()
    ) {
        self.dateKey = dateKey
        self.mood = mood
        self.intention = intention
        self.note = note
        self.createdAt = createdAt
    }
}

/// Shared formatter helpers for day keys used by check-ins and shloka pinning.
enum DayKey {
    static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    /// "yyyy-MM-dd" for the given date.
    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }

    /// "MM-dd" (month-day) used for fixed-day content pinning.
    static func monthDay(from date: Date) -> String {
        String(string(from: date).dropFirst(5)) // drop "yyyy-"
    }
}
