import Foundation

/// A completed (or in-progress) record of a practice the user performed.
/// Drives streaks, points and history.
struct PracticeSession: Identifiable, Codable, Hashable {
    let id: String
    let practiceID: String
    let practiceTitle: String
    let kind: PracticeKind
    let date: Date
    let durationSeconds: Int
    let pointsEarned: Int
    let completed: Bool

    init(
        id: String = UUID().uuidString,
        practiceID: String,
        practiceTitle: String,
        kind: PracticeKind,
        date: Date = Date(),
        durationSeconds: Int,
        pointsEarned: Int,
        completed: Bool = true
    ) {
        self.id = id
        self.practiceID = practiceID
        self.practiceTitle = practiceTitle
        self.kind = kind
        self.date = date
        self.durationSeconds = durationSeconds
        self.pointsEarned = pointsEarned
        self.completed = completed
    }
}
