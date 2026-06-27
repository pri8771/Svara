import SwiftUI

/// Central design tokens for Svara: a warm, calm palette rooted in
/// deep indigo (night sky / depth), saffron (devotion / energy) and
/// cream (paper / warmth). Tokens are intentionally semantic so views
/// never reference raw hex values.
enum SvaraTheme {

    // MARK: - Brand palette

    enum Palette {
        /// Deep indigo — primary brand, used for dark surfaces and headings on cream.
        static let indigo = Color(hex: "#1E1B4B")
        static let indigoMuted = Color(hex: "#322E6E")
        static let indigoSoft = Color(hex: "#4B4699")

        /// Saffron — devotion and warmth; primary action color.
        static let saffron = Color(hex: "#F5A23B")
        static let saffronDeep = Color(hex: "#E07F1C")
        static let saffronSoft = Color(hex: "#FAD9A8")

        /// Cream — calm background.
        static let cream = Color(hex: "#FBF4E8")
        static let creamRaised = Color(hex: "#FFFDF8")

        /// Supporting accents for theming categories.
        static let gold = Color(hex: "#E8B04B")
        static let lotus = Color(hex: "#E0729A")
        static let sage = Color(hex: "#7FA98C")
        static let sky = Color(hex: "#6C8FD6")

        static let ink = Color(hex: "#241F45")
        static let inkSecondary = Color(hex: "#6A6486")
    }

    // MARK: - Semantic colors

    enum Colors {
        static let background = Palette.cream
        static let surface = Palette.creamRaised
        static let surfaceInverse = Palette.indigo

        static let primary = Palette.saffron
        static let primaryDeep = Palette.saffronDeep
        static let accent = Palette.indigo

        static let textPrimary = Palette.ink
        static let textSecondary = Palette.inkSecondary
        static let textOnDark = Color(hex: "#FBF4E8")
        static let textOnPrimary = Color(hex: "#231300")

        static let separator = Color(hex: "#E7DCC8")
        static let success = Palette.sage
        static let streakFlame = Palette.saffronDeep
        static let points = Palette.gold
    }

    // MARK: - Gradients

    enum Gradients {
        static let dawn = LinearGradient(
            colors: [Palette.saffron, Palette.lotus],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let dusk = LinearGradient(
            colors: [Palette.indigo, Palette.indigoSoft],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let saffron = LinearGradient(
            colors: [Palette.saffron, Palette.saffronDeep],
            startPoint: .top,
            endPoint: .bottom
        )

        static func forTimeOfDay(_ time: TimeOfDay) -> LinearGradient {
            switch time {
            case .morning: return dawn
            case .afternoon: return saffron
            case .evening, .night: return dusk
            }
        }
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let screenMargin: CGFloat = 20
    }

    // MARK: - Radii

    enum Radius {
        static let sm: CGFloat = 10
        static let md: CGFloat = 16
        static let lg: CGFloat = 22
        static let pill: CGFloat = 999
    }

    // MARK: - Shadows

    enum Shadow {
        static let card = (color: Color.black.opacity(0.06), radius: CGFloat(14), x: CGFloat(0), y: CGFloat(6))
        static let raised = (color: Color.black.opacity(0.12), radius: CGFloat(18), x: CGFloat(0), y: CGFloat(10))
    }
}
