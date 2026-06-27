import SwiftUI

/// The visual language of the mandir: a darkened sacred space lit by lamplight.
/// Warm near-black ground, brass and marigold detailing, a living flame. The
/// altar should feel like a room at dusk with a single diya burning.
enum Theme {
    enum Palette {
        /// Warm near-black — the dim room around the altar.
        static let background = Color(hex: "#100D0A")
        /// Raised dark surface for quiet panels.
        static let surface = Color(hex: "#1A1510")
        /// The most-raised surface for cards and the altar plinth.
        static let surfaceRaised = Color(hex: "#241C14")
        /// Brass — fine detail, dividers, Devanagari, restrained metal.
        static let brass = Color(hex: "#C89B45")
        /// Marigold gold — the devotional accent and primary actions.
        static let marigold = Color(hex: "#F2A521")
        /// Living flame — the lit lamp and its glow.
        static let flame = Color(hex: "#FFB347")

        /// Warm cream — primary text on the dark ground.
        static let ink = Color(hex: "#F3E9D6")
        /// Muted warm grey — secondary text.
        static let inkSecondary = Color(hex: "#A99B82")
        /// The single accent for primary actions (marigold).
        static let accent = marigold
        /// Quiet sage for moods and moments of peace.
        static let calm = Color(hex: "#8FA07E")
        /// Hairline separators on the dark ground.
        static let hairline = Color(hex: "#2E2519")
    }

    enum Metrics {
        static let cornerRadius: CGFloat = 18
        static let cardPadding: CGFloat = 20
        static let screenPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 28
    }
}
