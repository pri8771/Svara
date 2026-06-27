import Foundation

/// Central registry of features, staged by the product doctrine's three
/// horizons: the **Private Mandir** (v0, shipping), the **Family** mandir (v1),
/// and the **Temple-Connected** mandir (v2).
///
/// Feature code branches on `FeatureFlag.x.isEnabled` so the v1/v2 surface is
/// wired but inert. Only the v0 set is live; flipping a flag is the entire cost
/// of turning a later feature on.
enum FeatureFlag: String, CaseIterable {
    // MARK: v0 — Private Mandir (always on)
    case onboarding
    case sankalp
    case reflections
    case memories
    case sacredTime
    case privateOfferings
    case returnThread

    // MARK: v1 — Family (off in v0)
    case familyMandir
    case sharedSankalps
    case familyObservances
    case ancestorDates
    case familyMemories
    case privateFamilySync

    // MARK: v2 — Temple-Connected (off in v0)
    case templeRelationships
    case templeVerification
    case templeRitualEvents
    case sevaParticipation
    case priestReviewedGuidance
    case templeAnnouncements

    /// The horizon a flag belongs to.
    enum Horizon: String {
        case v0 = "v0 · Private Mandir"
        case v1 = "v1 · Family"
        case v2 = "v2 · Temple-Connected"
    }

    var horizon: Horizon {
        switch self {
        case .onboarding, .sankalp, .reflections, .memories, .sacredTime,
             .privateOfferings, .returnThread:
            return .v0
        case .familyMandir, .sharedSankalps, .familyObservances, .ancestorDates,
             .familyMemories, .privateFamilySync:
            return .v1
        case .templeRelationships, .templeVerification, .templeRitualEvents,
             .sevaParticipation, .priestReviewedGuidance, .templeAnnouncements:
            return .v2
        }
    }

    /// Live in this build: the entire v0 horizon, nothing else.
    var isEnabled: Bool { horizon == .v0 }

    /// Human-readable label for the (debug-only) flag inspector.
    var title: String {
        switch self {
        case .onboarding: return "Onboarding"
        case .sankalp: return "Sankalp"
        case .reflections: return "Reflections"
        case .memories: return "Memories"
        case .sacredTime: return "Sacred Time"
        case .privateOfferings: return "Private Offerings"
        case .returnThread: return "Return Thread"
        case .familyMandir: return "Family Mandir"
        case .sharedSankalps: return "Shared Sankalps"
        case .familyObservances: return "Family Observances"
        case .ancestorDates: return "Ancestor Dates"
        case .familyMemories: return "Family Memories"
        case .privateFamilySync: return "Private Family Sync"
        case .templeRelationships: return "Temple Relationships"
        case .templeVerification: return "Temple Verification"
        case .templeRitualEvents: return "Temple Ritual Events"
        case .sevaParticipation: return "Seva Participation"
        case .priestReviewedGuidance: return "Priest-Reviewed Guidance"
        case .templeAnnouncements: return "Temple Announcements"
        }
    }
}
