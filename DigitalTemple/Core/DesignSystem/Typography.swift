import SwiftUI

/// Type scale for the mandir. Uses the system serif for a calm, scriptural
/// feel in titles, and the rounded system font for body warmth. Everything is
/// Dynamic-Type friendly (relativeTo:) so the app respects accessibility sizes.
extension Font {
    /// Large, quiet title — the name of the mandir.
    static let mandirTitle = Font.system(.largeTitle, design: .serif).weight(.semibold)
    /// Section / screen titles.
    static let sacredTitle = Font.system(.title2, design: .serif).weight(.semibold)
    /// Card headings.
    static let sacredHeadline = Font.system(.headline, design: .serif)
    /// Devanagari / Sanskrit display line.
    static let devanagari = Font.system(.title3, design: .serif)
    /// Body copy.
    static let sacredBody = Font.system(.body, design: .rounded)
    /// Supporting / caption text.
    static let sacredCaption = Font.system(.subheadline, design: .rounded)
    /// Small labels.
    static let sacredLabel = Font.system(.footnote, design: .rounded).weight(.medium)
}
