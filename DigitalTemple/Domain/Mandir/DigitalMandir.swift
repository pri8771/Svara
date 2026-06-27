import Foundation
import SwiftData

/// The person's private Digital Mandir — the anchor of the whole app. There is
/// exactly one in v0. It holds the name of the sacred space and the devata that
/// presides over it.
@Model
final class DigitalMandir {
    @Attribute(.unique) var id: UUID
    /// The name the person gives their mandir, e.g. "Aai's Corner".
    var name: String
    /// The presiding devata, chosen during onboarding.
    var primaryDevataId: UUID?
    var createdDate: Date

    init(
        id: UUID = UUID(),
        name: String,
        primaryDevataId: UUID? = nil,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.primaryDevataId = primaryDevataId
        self.createdDate = createdDate
    }
}
