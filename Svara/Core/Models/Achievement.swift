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

        // Authoring-friendly JSON shape: {"type": "streakDays", "value": 3}.
        // Cleaner than Swift's synthesized associated-value encoding and maps
        // directly to a Firestore field pair later.
        private enum CodingKeys: String, CodingKey { case type, value }
        private enum Kind: String, Codable {
            case streakDays, totalPractices, totalPoints, lessonsCompleted, festivalsObserved
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let kind = try container.decode(Kind.self, forKey: .type)
            let value = try container.decode(Int.self, forKey: .value)
            switch kind {
            case .streakDays: self = .streakDays(value)
            case .totalPractices: self = .totalPractices(value)
            case .totalPoints: self = .totalPoints(value)
            case .lessonsCompleted: self = .lessonsCompleted(value)
            case .festivalsObserved: self = .festivalsObserved(value)
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .streakDays(let v): try container.encode(Kind.streakDays, forKey: .type); try container.encode(v, forKey: .value)
            case .totalPractices(let v): try container.encode(Kind.totalPractices, forKey: .type); try container.encode(v, forKey: .value)
            case .totalPoints(let v): try container.encode(Kind.totalPoints, forKey: .type); try container.encode(v, forKey: .value)
            case .lessonsCompleted(let v): try container.encode(Kind.lessonsCompleted, forKey: .type); try container.encode(v, forKey: .value)
            case .festivalsObserved(let v): try container.encode(Kind.festivalsObserved, forKey: .type); try container.encode(v, forKey: .value)
            }
        }
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
