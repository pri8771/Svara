import Foundation
import SwiftData

/// Regions of cultural relevance for a sacred date. Used to gently note where
/// an observance is most kept — never to gate content.
enum Region: String, Codable, CaseIterable, Identifiable {
    case panIndia
    case north
    case south
    case east
    case west
    case diaspora

    var id: String { rawValue }

    var title: String {
        switch self {
        case .panIndia: return "Pan-India"
        case .north: return "North India"
        case .south: return "South India"
        case .east: return "East India"
        case .west: return "West India"
        case .diaspora: return "Diaspora"
        }
    }
}

/// An entry in Sacred Time — a festival, vrat, or observance the person may
/// wish to remember. Seeded from `sacredDates.json`.
@Model
final class SacredDateEntry {
    @Attribute(.unique) var id: UUID
    var name: String
    var nameDevanagari: String?
    /// The reference date. For yearly-recurring entries the month and day are
    /// what matter; the year is normalised forward at read time.
    var date: Date
    var yearlyRecurring: Bool
    var devataAssociation: String?
    var significance: String
    var regionRelevance: [Region]
    var tradition: String?

    init(
        id: UUID = UUID(),
        name: String,
        nameDevanagari: String? = nil,
        date: Date,
        yearlyRecurring: Bool = true,
        devataAssociation: String? = nil,
        significance: String,
        regionRelevance: [Region] = [.panIndia],
        tradition: String? = nil
    ) {
        self.id = id
        self.name = name
        self.nameDevanagari = nameDevanagari
        self.date = date
        self.yearlyRecurring = yearlyRecurring
        self.devataAssociation = devataAssociation
        self.significance = significance
        self.regionRelevance = regionRelevance
        self.tradition = tradition
    }

    /// The next time this observance occurs, accounting for yearly recurrence.
    var nextOccurrence: Date {
        yearlyRecurring ? date.nextYearlyOccurrence() : date
    }
}
