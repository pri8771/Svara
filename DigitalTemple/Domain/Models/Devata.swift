import Foundation
import SwiftData

/// A devata (deity) the person may welcome into their mandir. Seeded from
/// `devatas.json` on first launch — never user-created. The person chooses
/// which devatas reside in their space by toggling `isChosen`.
@Model
final class Devata {
    @Attribute(.unique) var id: UUID
    var name: String
    var nameDevanagari: String
    /// Sampradaya / tradition association, e.g. "Shaiva", "Vaishnava", "Shakta".
    var tradition: String
    var summary: String
    /// A short note on what this devata symbolises for the devotee.
    var symbolicNote: String
    var isChosen: Bool

    init(
        id: UUID = UUID(),
        name: String,
        nameDevanagari: String,
        tradition: String,
        summary: String,
        symbolicNote: String,
        isChosen: Bool = false
    ) {
        self.id = id
        self.name = name
        self.nameDevanagari = nameDevanagari
        self.tradition = tradition
        self.summary = summary
        self.symbolicNote = symbolicNote
        self.isChosen = isChosen
    }
}
