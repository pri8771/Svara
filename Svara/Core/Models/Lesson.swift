import Foundation

/// A Duolingo-style lesson that teaches a mantra or sloka step by step.
struct Lesson: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let theme: SpiritualTheme
    /// 1-based difficulty / ordering within a track.
    let level: Int
    /// XP (Svara Points) awarded for completing every step.
    let xp: Int
    let mantraID: String?
    let steps: [LessonStep]
    /// Whether the lesson requires premium access.
    let isPremium: Bool

    var stepCount: Int { steps.count }

    init(
        id: String,
        title: String,
        subtitle: String,
        theme: SpiritualTheme,
        level: Int,
        xp: Int = 20,
        mantraID: String? = nil,
        steps: [LessonStep],
        isPremium: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.theme = theme
        self.level = level
        self.xp = xp
        self.mantraID = mantraID
        self.steps = steps
        self.isPremium = isPremium
    }
}

/// One interactive screen within a lesson.
struct LessonStep: Identifiable, Codable, Hashable {
    enum Kind: String, Codable, Hashable {
        case intro       // explanatory card, no interaction
        case listen      // listen / chant along
        case meaning     // present the meaning
        case multipleChoice
        case fillBlank
    }

    let id: String
    let kind: Kind
    let prompt: String
    /// Supporting body text (meaning, instruction, etc.).
    let detail: String?
    /// Answer options for quiz steps.
    let options: [String]
    /// Index into `options` for the correct answer (quiz steps only).
    let correctIndex: Int?

    init(
        id: String,
        kind: Kind,
        prompt: String,
        detail: String? = nil,
        options: [String] = [],
        correctIndex: Int? = nil
    ) {
        self.id = id
        self.kind = kind
        self.prompt = prompt
        self.detail = detail
        self.options = options
        self.correctIndex = correctIndex
    }

    var isInteractive: Bool { kind == .multipleChoice || kind == .fillBlank }
}
