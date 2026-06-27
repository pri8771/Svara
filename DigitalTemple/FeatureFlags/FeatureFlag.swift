import Foundation

/// Central registry of features. v0 ships only the sacred-relationship core;
/// everything planned for v1/v2 is declared here and flagged off so feature
/// code can branch on `FeatureFlag.x.isEnabled` without a later refactor.
///
/// To turn a feature on, flip its entry in `enabledFlags`. Nothing in v0
/// reads a flag that is on, so the default build is the quiet v0 experience.
enum FeatureFlag: String, CaseIterable {
    // MARK: v0 (always on)
    case onboarding
    case sankalp
    case reflections
    case memories
    case sacredTime

    // MARK: v1 (planned — off in v0)
    case dailyDarshan          // a gentle daily return ritual
    case sankalpReminders      // local notifications for sacred dates
    case iCloudSync            // private sync across a person's devices
    case multipleMandirs       // family / lineage mandirs

    // MARK: v2 (planned — off in v0)
    case sharedMandir          // a household sharing one sacred space
    case guidedRituals         // optional step-by-step observances
    case lineageMemories       // memories passed between generations

    /// Flags that are live in this build.
    private static let enabledFlags: Set<FeatureFlag> = [
        .onboarding, .sankalp, .reflections, .memories, .sacredTime
    ]

    var isEnabled: Bool { Self.enabledFlags.contains(self) }

    /// Human-readable label, used by the (debug-only) flag inspector.
    var title: String {
        switch self {
        case .onboarding: return "Onboarding"
        case .sankalp: return "Sankalp"
        case .reflections: return "Reflections"
        case .memories: return "Memories"
        case .sacredTime: return "Sacred Time"
        case .dailyDarshan: return "Daily Darshan"
        case .sankalpReminders: return "Sankalp Reminders"
        case .iCloudSync: return "iCloud Sync"
        case .multipleMandirs: return "Multiple Mandirs"
        case .sharedMandir: return "Shared Mandir"
        case .guidedRituals: return "Guided Rituals"
        case .lineageMemories: return "Lineage Memories"
        }
    }
}
