import SwiftUI

/// Time-of-day buckets used to theme the app and schedule practices.
enum TimeOfDay: String, Codable, CaseIterable, Hashable {
    case morning
    case afternoon
    case evening
    case night

    var label: String {
        switch self {
        case .morning: return "Morning"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        case .night: return "Night"
        }
    }

    var systemImage: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "sunset.fill"
        case .night: return "moon.stars.fill"
        }
    }

    /// Derives the bucket from an hour of the day (0–23).
    static func from(hour: Int) -> TimeOfDay {
        switch hour {
        case 5..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<21: return .evening
        default: return .night
        }
    }
}

/// The kind of daily practice offered on the Today screen.
enum PracticeKind: String, Codable, CaseIterable, Hashable {
    case mantra
    case prayer
    case breathing
    case reflection
    case gratitude

    var label: String {
        switch self {
        case .mantra: return "Mantra"
        case .prayer: return "Prayer"
        case .breathing: return "Breathwork"
        case .reflection: return "Reflection"
        case .gratitude: return "Gratitude"
        }
    }

    var systemImage: String {
        switch self {
        case .mantra: return "waveform"
        case .prayer: return "hands.and.sparkles.fill"
        case .breathing: return "wind"
        case .reflection: return "book.closed.fill"
        case .gratitude: return "heart.fill"
        }
    }
}

/// Spiritual themes used to organise stories, symbols and lessons.
enum SpiritualTheme: String, Codable, CaseIterable, Hashable, Identifiable {
    case courage
    case wisdom
    case devotion
    case prosperity
    case compassion
    case discipline
    case knowledge
    case protection

    var id: String { rawValue }

    var label: String {
        switch self {
        case .courage: return "Courage"
        case .wisdom: return "Wisdom"
        case .devotion: return "Devotion"
        case .prosperity: return "Prosperity"
        case .compassion: return "Compassion"
        case .discipline: return "Discipline"
        case .knowledge: return "Knowledge"
        case .protection: return "Protection"
        }
    }

    var systemImage: String {
        switch self {
        case .courage: return "flame.fill"
        case .wisdom: return "brain.head.profile"
        case .devotion: return "heart.circle.fill"
        case .prosperity: return "leaf.fill"
        case .compassion: return "hands.sparkles.fill"
        case .discipline: return "figure.mind.and.body"
        case .knowledge: return "books.vertical.fill"
        case .protection: return "shield.fill"
        }
    }

    var colorHex: String {
        switch self {
        case .courage: return "#E07F1C"
        case .wisdom: return "#6C8FD6"
        case .devotion: return "#E0729A"
        case .prosperity: return "#7FA98C"
        case .compassion: return "#F5A23B"
        case .discipline: return "#4B4699"
        case .knowledge: return "#E8B04B"
        case .protection: return "#322E6E"
        }
    }

    var color: Color { Color(hex: colorHex) }
}
