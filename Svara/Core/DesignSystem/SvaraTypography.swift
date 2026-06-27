import SwiftUI

/// Typography scale for Svara. Uses the system serif for devotional/heading
/// content (warmth, tradition) and the default rounded/sans for UI chrome.
extension Font {
    static let svaraDisplay = Font.system(.largeTitle, design: .serif).weight(.bold)
    static let svaraTitle = Font.system(.title2, design: .serif).weight(.semibold)
    static let svaraHeadline = Font.system(.headline, design: .rounded).weight(.semibold)
    static let svaraBody = Font.system(.body, design: .default)
    static let svaraCallout = Font.system(.callout, design: .default)
    static let svaraCaption = Font.system(.caption, design: .rounded)

    /// For Sanskrit / Devanagari and transliteration display lines.
    static let svaraSanskrit = Font.system(.title3, design: .serif).weight(.medium)
}

extension Text {
    /// Applies the section-eyebrow style (uppercase, tracked, secondary).
    func svaraEyebrow() -> some View {
        self
            .font(.svaraCaption.weight(.bold))
            .textCase(.uppercase)
            .tracking(1.4)
            .foregroundStyle(SvaraTheme.Colors.textSecondary)
    }
}
