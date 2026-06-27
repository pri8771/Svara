import Foundation

/// A badge the user can earn. Requirements are evaluated against the
/// user's progress by `ProgressService`.
struct Achievement: Identifiable, Codable, Hashable {
    enum Requirement: Codable, Hashable {
        case streakDays(Int)
        case totalPractices(Int)
        case totalPoints(Int)
        case lessonsCompleted(Int)
        case festivalsObserved(Int)
    }

    let id: String
    let title: String
    let detail: String
    let systemImage: String
    let requirement: Requirement
    /// Svara Points granted when the achievement unlocks.
    let bonusPoints: Int

    init(
        id: String,
        title: String,
        detail: String,
        systemImage: String,
        requirement: Requirement,
        bonusPoints: Int = 50
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.systemImage = systemImage
        self.requirement = requirement
        self.bonusPoints = bonusPoints
    }

    /// A human-readable progress target for the requirement.
    var target: Int {
        switch requirement {
        case .streakDays(let n),
             .totalPractices(let n),
             .totalPoints(let n),
             .lessonsCompleted(let n),
             .festivalsObserved(let n):
            return n
        }
    }
}
