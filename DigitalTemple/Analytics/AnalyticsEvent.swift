import Foundation

/// Every meaningful moment in the sacred-relationship lifecycle.
///
/// Events are intentionally about *devotional* actions, never engagement
/// metrics — there is no "session length", no "streak", no "daily active".
/// Each case carries a stable `name` (snake_case, Firebase-friendly) and a
/// `parameters` dictionary so `AnalyticsService` can forward to any backend
/// (console in v0, Firebase Analytics later) without touching call sites.
enum AnalyticsEvent {
    // Onboarding
    case onboardingStarted
    case onboardingIntentionSelected(intention: String)
    case mandirNamed
    case devatasChosen(count: Int)
    case onboardingCompleted(createdSankalp: Bool)

    // Mandir
    case mandirOpened
    case altarLit                             // the lamp lit via the hold-wick return
    case mandirModeSelected(mode: String)     // altar / offer / reflect / thread

    // Offerings
    case offeringMade(kind: String)

    // Thread
    case threadViewed

    // Sankalp
    case sankalpCreated(type: String)
    case sankalpFulfilled(type: String)
    case sankalpViewed

    // Reflection
    case reflectionAdded(mood: String)

    // Memory
    case memorySaved(type: String)
    case memoriesViewed

    // Sacred time
    case sacredTimeViewed

    // Settings
    case devotionalIdentityEdited

    var name: String {
        switch self {
        case .onboardingStarted: return "onboarding_started"
        case .onboardingIntentionSelected: return "onboarding_intention_selected"
        case .mandirNamed: return "mandir_named"
        case .devatasChosen: return "devatas_chosen"
        case .onboardingCompleted: return "onboarding_completed"
        case .mandirOpened: return "mandir_opened"
        case .altarLit: return "altar_lit"
        case .mandirModeSelected: return "mandir_mode_selected"
        case .offeringMade: return "offering_made"
        case .threadViewed: return "thread_viewed"
        case .sankalpCreated: return "sankalp_created"
        case .sankalpFulfilled: return "sankalp_fulfilled"
        case .sankalpViewed: return "sankalp_viewed"
        case .reflectionAdded: return "reflection_added"
        case .memorySaved: return "memory_saved"
        case .memoriesViewed: return "memories_viewed"
        case .sacredTimeViewed: return "sacred_time_viewed"
        case .devotionalIdentityEdited: return "devotional_identity_edited"
        }
    }

    var parameters: [String: Any] {
        switch self {
        case let .onboardingIntentionSelected(intention):
            return ["intention": intention]
        case let .devatasChosen(count):
            return ["count": count]
        case let .onboardingCompleted(createdSankalp):
            return ["created_sankalp": createdSankalp]
        case let .sankalpCreated(type), let .sankalpFulfilled(type):
            return ["intention_type": type]
        case let .reflectionAdded(mood):
            return ["mood": mood]
        case let .mandirModeSelected(mode):
            return ["mode": mode]
        case let .offeringMade(kind):
            return ["offering_kind": kind]
        case let .memorySaved(type):
            return ["memory_type": type]
        default:
            return [:]
        }
    }
}
