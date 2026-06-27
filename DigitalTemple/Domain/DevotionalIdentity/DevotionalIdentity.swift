import Foundation
import SwiftData

/// How the person relates to their mandir: how they wish to be known, the
/// intention that brought them here, and any tradition they lean toward. Kept
/// separate from the mandir itself so it can be edited from Settings without
/// disturbing the sacred space.
@Model
final class DevotionalIdentity {
    @Attribute(.unique) var id: UUID
    /// How the person wishes to be addressed in their space (optional).
    var displayName: String
    /// The onboarding intention ("Why are you here?"), stored by raw value.
    var onboardingIntention: String
    /// An optional tradition the person feels closest to (Shaiva / Vaishnava /
    /// Shakta / etc.). Free-form and never required.
    var traditionLeaning: String?
    var mandirId: UUID

    init(
        id: UUID = UUID(),
        displayName: String = "",
        onboardingIntention: String,
        traditionLeaning: String? = nil,
        mandirId: UUID
    ) {
        self.id = id
        self.displayName = displayName
        self.onboardingIntention = onboardingIntention
        self.traditionLeaning = traditionLeaning
        self.mandirId = mandirId
    }
}
