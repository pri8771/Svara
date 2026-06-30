import Foundation

/// A regional lens for personalising the Festivals tab. Filtering is **gentle
/// and non-blocking** — choosing a region re-orders and highlights relevant
/// festivals but never hides the rest (see `FestivalRegionFilter`).
enum FestivalRegion: String, Codable, CaseIterable, Identifiable, Hashable {
    case india
    case diaspora
    case northIndia
    case southIndia
    case westIndia
    case eastIndia
    case global

    var id: String { rawValue }

    var label: String {
        switch self {
        case .india: return "India"
        case .diaspora: return "Diaspora"
        case .northIndia: return "North India"
        case .southIndia: return "South India"
        case .westIndia: return "West India"
        case .eastIndia: return "East India"
        case .global: return "Global Hindu"
        }
    }

    var systemImage: String {
        switch self {
        case .india: return "map.fill"
        case .diaspora: return "airplane"
        case .northIndia: return "mountain.2.fill"
        case .southIndia: return "leaf.fill"
        case .westIndia: return "sun.haze.fill"
        case .eastIndia: return "drop.fill"
        case .global: return "globe.asia.australia.fill"
        }
    }
}
