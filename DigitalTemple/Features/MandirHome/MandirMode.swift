import SwiftUI

/// The ways a person engages their altar. Not a tab bar — a single in-place
/// selector that swaps the surface beneath the persistent altar. "Altar" is
/// simply being present; the others are acts of relationship.
enum MandirMode: String, CaseIterable, Identifiable {
    case altar
    case offer
    case reflect
    case thread

    var id: String { rawValue }

    var title: String {
        switch self {
        case .altar: return "Altar"
        case .offer: return "Offer"
        case .reflect: return "Reflect"
        case .thread: return "Thread"
        }
    }

    var glyph: String {
        switch self {
        case .altar: return "🪔"
        case .offer: return "🌼"
        case .reflect: return "🍃"
        case .thread: return "🧵"
        }
    }
}
