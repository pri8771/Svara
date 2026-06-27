import SwiftUI

/// The visual language of the mandir: warm, quiet, devotional. Earth and
/// lamplight rather than screens and feeds. All colors are defined here so the
/// whole app shares one calm palette.
enum Theme {
    enum Palette {
        /// Warm sandalwood paper — the resting background of the sacred space.
        static let background = Color(hex: "#F6EFE3")
        /// Slightly raised surface for cards.
        static let surface = Color(hex: "#FBF6EC")
        /// Deep temple maroon — primary text and weighty actions.
        static let ink = Color(hex: "#3A2A24")
        /// Softer ink for secondary text.
        static let inkSecondary = Color(hex: "#7A6A60")
        /// Saffron flame — the single accent, used sparingly.
        static let accent = Color(hex: "#B8533A")
        /// Muted gold for fine detail (dividers, sacred-date glyphs).
        static let gold = Color(hex: "#C9A24B")
        /// Quiet sage for a sense of peace (used in moods, fulfillment).
        static let calm = Color(hex: "#8A9A7B")
        /// Hairline separators.
        static let hairline = Color(hex: "#E3D8C5")
    }

    enum Metrics {
        static let cornerRadius: CGFloat = 18
        static let cardPadding: CGFloat = 20
        static let screenPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 28
    }
}
