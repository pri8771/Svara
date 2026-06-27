import SwiftUI

/// Svara's canonical symbol system.
///
/// Per product review, the **bell is intentionally excluded** — it reads as
/// too "temple-coded" for a wellness app. The six approved symbols are:
/// Lotus, Diya, Om, Dawn, Mandala, Sunrise.
///
/// SF Symbol names below are interim placeholders; bespoke artwork will replace
/// them (Phase 2+). Om renders best as the Unicode glyph `ॐ` via `glyph`.
enum SvaraSymbol: String, CaseIterable, Identifiable {
    case lotus
    case diya
    case om
    case dawn
    case mandala
    case sunrise

    var id: String { rawValue }

    var label: String {
        switch self {
        case .lotus: return "Lotus"
        case .diya: return "Diya"
        case .om: return "Om"
        case .dawn: return "Dawn"
        case .mandala: return "Mandala"
        case .sunrise: return "Sunrise"
        }
    }

    /// Interim SF Symbol placeholder. Replace with custom art when available.
    var systemImage: String {
        switch self {
        case .lotus: return "camera.macro"        // flower-like placeholder
        case .diya: return "flame.fill"
        case .om: return "circle.circle"          // placeholder; prefer `glyph`
        case .dawn: return "sunrise.fill"
        case .mandala: return "circle.hexagongrid.fill"
        case .sunrise: return "sun.and.horizon.fill"
        }
    }

    /// Preferred textual glyph where one reads better than an SF Symbol.
    var glyph: String? {
        switch self {
        case .om: return "ॐ"
        default: return nil
        }
    }
}
