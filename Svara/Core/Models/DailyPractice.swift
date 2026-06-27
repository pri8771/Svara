import SwiftUI

/// A single bite-sized (~3 minute) practice surfaced on the Today screen.
struct DailyPractice: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let kind: PracticeKind
    let timeOfDay: TimeOfDay
    let durationMinutes: Int
    /// Svara Points awarded on completion.
    let points: Int
    /// Optional mantra this practice centres on.
    let mantraID: String?
    /// Short guidance shown while practising.
    let guidance: [String]

    var systemImage: String { kind.systemImage }

    init(
        id: String,
        title: String,
        subtitle: String,
        kind: PracticeKind,
        timeOfDay: TimeOfDay,
        durationMinutes: Int = 3,
        points: Int = 10,
        mantraID: String? = nil,
        guidance: [String] = []
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.kind = kind
        self.timeOfDay = timeOfDay
        self.durationMinutes = durationMinutes
        self.points = points
        self.mantraID = mantraID
        self.guidance = guidance
    }
}
