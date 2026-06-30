import Foundation

/// A Duolingo-style lesson that teaches a mantra or sloka step by step.
///
/// Phase 2B: lessons can sit on the **Aaroh Path** (`pathDay` 1...N), carry a
/// short `meaningOverview` and `pronunciationTip`, and unlock one piece of
/// meaning on completion (`insightTitle` / `insightBody`). All new fields are
/// optional so older JSON keeps decoding unchanged.
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

    /// Position on the beginner Aaroh Path (1...7). `nil` = not on the guided path.
    let pathDay: Int?
    /// A one-line plain-language overview of what this lesson teaches.
    let meaningOverview: String?
    /// A gentle, non-judgemental pronunciation tip.
    let pronunciationTip: String?
    /// The headline of the meaning unlocked on completion, e.g. "What Vakratunda means".
    let insightTitle: String?
    /// The body of the unlocked meaning shown on the result screen.
    let insightBody: String?

    // Provenance (optional; see ContentProvenanceCarrying).
    let sourceName: String?
    let sourceNote: String?
    let traditionNote: String?
    let reviewStatus: ContentReviewStatus?

    var stepCount: Int { steps.count }

    /// Quiz steps that the learner actually answers (drives the score).
    var quizSteps: [LessonStep] { steps.filter(\.isInteractive) }
    var quizCount: Int { quizSteps.count }

    /// Whether this lesson sits on the guided beginner path.
    var isOnPath: Bool { pathDay != nil }

    /// Authoring-friendly initialiser: optional metadata is declared before
    /// `steps` so seed content can read top-down (overview → insight → steps),
    /// with the long `steps` array last. Codable is synthesised from stored
    /// property order and is unaffected by this parameter ordering.
    init(
        id: String,
        title: String,
        subtitle: String,
        theme: SpiritualTheme,
        level: Int,
        xp: Int = 20,
        mantraID: String? = nil,
        isPremium: Bool = false,
        pathDay: Int? = nil,
        meaningOverview: String? = nil,
        pronunciationTip: String? = nil,
        insightTitle: String? = nil,
        insightBody: String? = nil,
        sourceName: String? = nil,
        sourceNote: String? = nil,
        traditionNote: String? = nil,
        reviewStatus: ContentReviewStatus? = nil,
        steps: [LessonStep]
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
        self.pathDay = pathDay
        self.meaningOverview = meaningOverview
        self.pronunciationTip = pronunciationTip
        self.insightTitle = insightTitle
        self.insightBody = insightBody
        self.sourceName = sourceName
        self.sourceNote = sourceNote
        self.traditionNote = traditionNote
        self.reviewStatus = reviewStatus
    }
}

extension Lesson: ContentProvenanceCarrying {}

/// One interactive screen within a lesson.
struct LessonStep: Identifiable, Codable, Hashable {
    enum Kind: String, Codable, Hashable {
        case intro          // explanatory card, no interaction
        case listen         // listen / chant along
        case meaning        // present the meaning
        case reflection     // a gentle prompt to pause and reflect (no right answer)
        case multipleChoice // pick the correct option
        case matchMeaning   // match a word/line to its meaning (option-based)
        case fillBlank      // complete a line (options or free text)
        case syllableOrder  // arrange syllables into the correct order
    }

    let id: String
    let kind: Kind
    let prompt: String
    /// Supporting body text (meaning, instruction, etc.).
    let detail: String?
    /// Answer options for option-based quiz steps.
    let options: [String]
    /// Index into `options` for the correct answer (option-based steps).
    let correctIndex: Int?
    /// Accepted answers for a free-text `fillBlank` (case/space-insensitive match).
    let acceptedAnswers: [String]
    /// The correct ordering of syllables for a `syllableOrder` step.
    let syllables: [String]
    /// A gentle hint the learner can reveal (never punitive; tracked, not penalised).
    let hint: String?

    init(
        id: String,
        kind: Kind,
        prompt: String,
        detail: String? = nil,
        options: [String] = [],
        correctIndex: Int? = nil,
        acceptedAnswers: [String] = [],
        syllables: [String] = [],
        hint: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.prompt = prompt
        self.detail = detail
        self.options = options
        self.correctIndex = correctIndex
        self.acceptedAnswers = acceptedAnswers
        self.syllables = syllables
        self.hint = hint
    }

    // Custom decoding so JSON may omit the newer array fields and older content
    // keeps decoding unchanged.
    enum CodingKeys: String, CodingKey {
        case id, kind, prompt, detail, options, correctIndex, acceptedAnswers, syllables, hint
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        kind = try c.decode(Kind.self, forKey: .kind)
        prompt = try c.decode(String.self, forKey: .prompt)
        detail = try c.decodeIfPresent(String.self, forKey: .detail)
        options = try c.decodeIfPresent([String].self, forKey: .options) ?? []
        correctIndex = try c.decodeIfPresent(Int.self, forKey: .correctIndex)
        acceptedAnswers = try c.decodeIfPresent([String].self, forKey: .acceptedAnswers) ?? []
        syllables = try c.decodeIfPresent([String].self, forKey: .syllables) ?? []
        hint = try c.decodeIfPresent(String.self, forKey: .hint)
    }

    /// A step the learner answers (as opposed to a reading/listening card).
    var isInteractive: Bool {
        switch kind {
        case .multipleChoice, .matchMeaning, .fillBlank, .syllableOrder: return true
        case .intro, .listen, .meaning, .reflection: return false
        }
    }

    /// Whether this step has a single objectively-correct answer (so it can be
    /// scored). Reflection steps are interactive in spirit but never "wrong".
    var isScored: Bool { isInteractive }
}
