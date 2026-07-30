import Foundation

/// Svara's primary navigation surfaces, as a testable registry kept separate
/// from the SwiftUI view so guardrail invariants can reason about it directly.
///
/// There is intentionally **no** feed, community, followers, public profile,
/// comments or leaderboard case here: in-app social-graph surfaces are forbidden
/// by `ProductGuardrails.md` ("private, not a feed"). `Profile` is the user's own
/// local, private screen.
enum MainTab: String, CaseIterable, Hashable, Identifiable {
    case today, learn, festivals, stories, profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "Today"
        case .learn: return "Learn"
        case .festivals: return "Festivals"
        case .stories: return "Stories"
        case .profile: return "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .today: return "sun.and.horizon.fill"
        case .learn: return "graduationcap.fill"
        case .festivals: return "sparkles"
        case .stories: return "text.book.closed.fill"
        case .profile: return "person.fill"
        }
    }

    /// Today (the daily-practice habit) and Learn (diaspora reconnection) are the
    /// irreducible core surface and can never be staged out of primary nav.
    var isCore: Bool { self == .today || self == .learn }
}

/// Launch configuration controlling which optional surfaces are part of the
/// primary experience.
///
/// Strategy lock (Codex↔Claude): the focused beta is **Today + Learn primary**,
/// with Festivals and Stories *staged out of primary navigation* behind a flag.
/// The shipping default (`.full`) is the complete, polished product; the
/// `.betaScope` preset reproduces the staged beta. `Today` and `Learn` are always
/// present and always first — `primaryTabs` enforces this structurally, so a
/// staged tab can never reappear as a core beta surface.
struct FeatureFlags: Equatable {
    var festivalsTab: Bool
    var storiesTab: Bool
    /// Outbound OS share sheet for cultural content. This is *not* an in-app
    /// social graph — it hands a short text to the system share sheet so a user
    /// can pass a festival on to a friend. Gated so the focused beta can omit it.
    var contentSharing: Bool
    /// Commerce is intentionally hidden for the owner-only testing build.
    /// Authored premium markers and StoreKit code remain available for a later,
    /// deliberate reactivation.
    var plusTierEnabled: Bool

    init(
        festivalsTab: Bool,
        storiesTab: Bool,
        contentSharing: Bool,
        plusTierEnabled: Bool = false
    ) {
        self.festivalsTab = festivalsTab
        self.storiesTab = storiesTab
        self.contentSharing = contentSharing
        self.plusTierEnabled = plusTierEnabled
    }

    /// The current full-surface testing product: all content is free and Plus
    /// has no visible entry point.
    static let full = FeatureFlags(
        festivalsTab: true,
        storiesTab: true,
        contentSharing: true,
        plusTierEnabled: false
    )

    /// Future monetized configuration retained for deliberate reactivation.
    static let monetizedFull = FeatureFlags(
        festivalsTab: true,
        storiesTab: true,
        contentSharing: true,
        plusTierEnabled: true
    )

    /// The strategy-lock beta: Today + Learn primary; Festivals/Stories + sharing staged out.
    static let betaScope = FeatureFlags(
        festivalsTab: false,
        storiesTab: false,
        contentSharing: false,
        plusTierEnabled: false
    )

    /// The configuration the app currently ships with.
    static let current = FeatureFlags.full

    /// Ordered primary tabs for these flags. Invariants (verified by
    /// `TabConfigurationTests`): Today and Learn are always the first two and
    /// always present; Profile is always last; Festivals/Stories appear only when
    /// their flag is on.
    var primaryTabs: [MainTab] {
        var tabs: [MainTab] = [.today, .learn]
        if festivalsTab { tabs.append(.festivals) }
        if storiesTab { tabs.append(.stories) }
        tabs.append(.profile)
        return tabs
    }
}
