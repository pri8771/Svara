import Foundation

/// A symbol that appears within a `Story` (e.g. Lotus, Veena, Crescent moon),
/// with a humble explanation of what it commonly represents.
struct SymbolEntry: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let sanskritName: String?
    /// 2–3 sentences on what the symbol commonly means.
    let meaning: String
    let associatedDeities: [String]
    /// Acknowledges that readings vary by tradition and region.
    let traditionNote: String

    init(
        id: String,
        name: String,
        sanskritName: String? = nil,
        meaning: String,
        associatedDeities: [String] = [],
        traditionNote: String = "Readings vary by tradition, region, and family lineage."
    ) {
        self.id = id
        self.name = name
        self.sanskritName = sanskritName
        self.meaning = meaning
        self.associatedDeities = associatedDeities
        self.traditionNote = traditionNote
    }
}
