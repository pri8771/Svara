import Foundation

/// A single content problem found by `ContentValidation`.
struct ValidationIssue: Equatable, CustomStringConvertible {
    enum Severity: String { case error, warning }
    let severity: Severity
    let context: String
    let message: String

    var description: String { "[\(severity.rawValue)] \(context): \(message)" }

    static func error(_ context: String, _ message: String) -> ValidationIssue {
        ValidationIssue(severity: .error, context: context, message: message)
    }
    static func warning(_ context: String, _ message: String) -> ValidationIssue {
        ValidationIssue(severity: .warning, context: context, message: message)
    }
}

/// Validates seed content against Svara's product guardrails:
/// required fields, valid lesson ordering, parseable festival dates, present
/// premium flags, and — importantly — **no forbidden Primandir-style terms**
/// in user-facing labels. See `ProductGuardrails.md`.
enum ContentValidation {

    /// Forbidden user-facing terms (case-insensitive). Matches the hard rules
    /// in ProductGuardrails.md §3.
    static let forbiddenTermList: [String] = [
        "virtual puja",
        "darshan booking",
        "offerings",
        "priest booking",
        "temple marketplace",
        "live temple"
    ]

    /// Returns any forbidden terms found within `text` (case-insensitive).
    static func forbiddenTerms(in text: String) -> [String] {
        let lower = text.lowercased()
        return forbiddenTermList.filter { lower.contains($0) }
    }

    // MARK: - Top-level

    static func validate(
        mantras: [Mantra],
        lessons: [Lesson],
        festivals: [Festival],
        stories: [StorySymbol],
        shlokas: [ShlokaOfDay],
        achievements: [Achievement]
    ) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        issues += validateMantras(mantras)
        issues += validateLessons(lessons)
        issues += validateFestivals(festivals)
        issues += validateStories(stories)
        issues += validateShlokas(shlokas)
        issues += validateAchievements(achievements)
        issues += scanForbiddenTerms(
            mantras: mantras, lessons: lessons, festivals: festivals,
            stories: stories, shlokas: shlokas, achievements: achievements
        )
        return issues
    }

    /// Convenience that pulls content from a provider and validates it.
    static func validate(using provider: SeedContentProvider) -> [ValidationIssue] {
        validate(
            mantras: provider.mantras,
            lessons: provider.lessons,
            festivals: provider.festivals,
            stories: provider.stories,
            shlokas: provider.shlokas,
            achievements: provider.achievements
        )
    }

    // MARK: - Per-type checks

    static func validateMantras(_ mantras: [Mantra]) -> [ValidationIssue] {
        var issues = checkUniqueIDs(mantras.map(\.id), context: "mantras")
        for m in mantras {
            let ctx = "mantra '\(m.id)'"
            if m.id.isEmpty { issues.append(.error(ctx, "empty id")) }
            if m.title.trimmed.isEmpty { issues.append(.error(ctx, "missing title")) }
            if m.transliteration.trimmed.isEmpty { issues.append(.error(ctx, "missing transliteration")) }
            if m.translation.trimmed.isEmpty { issues.append(.error(ctx, "missing translation")) }
            if m.meaning.trimmed.isEmpty { issues.append(.error(ctx, "missing meaning")) }
            if m.durationMinutes <= 0 { issues.append(.warning(ctx, "non-positive duration")) }
        }
        return issues
    }

    static func validateLessons(_ lessons: [Lesson]) -> [ValidationIssue] {
        var issues = checkUniqueIDs(lessons.map(\.id), context: "lessons")
        issues += validateLessonOrder(lessons)
        for lesson in lessons {
            let ctx = "lesson '\(lesson.id)'"
            if lesson.title.trimmed.isEmpty { issues.append(.error(ctx, "missing title")) }
            if lesson.steps.isEmpty { issues.append(.error(ctx, "has no steps")) }
            for step in lesson.steps where step.isInteractive {
                guard let idx = step.correctIndex else {
                    issues.append(.error(ctx, "quiz step '\(step.id)' missing correctIndex"))
                    continue
                }
                if step.options.isEmpty {
                    issues.append(.error(ctx, "quiz step '\(step.id)' has no options"))
                } else if idx < 0 || idx >= step.options.count {
                    issues.append(.error(ctx, "quiz step '\(step.id)' correctIndex out of range"))
                }
            }
        }
        return issues
    }

    /// Lesson order is valid when every level is >= 1 and levels are unique.
    static func validateLessonOrder(_ lessons: [Lesson]) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        var seen = Set<Int>()
        for lesson in lessons {
            if lesson.level < 1 {
                issues.append(.error("lesson '\(lesson.id)'", "level must be >= 1 (got \(lesson.level))"))
            }
            if !seen.insert(lesson.level).inserted {
                issues.append(.error("lessons", "duplicate level \(lesson.level)"))
            }
        }
        return issues
    }

    static func validateFestivals(_ festivals: [Festival]) -> [ValidationIssue] {
        var issues = checkUniqueIDs(festivals.map(\.id), context: "festivals")
        let calendar = Calendar(identifier: .gregorian)
        for f in festivals {
            let ctx = "festival '\(f.id)'"
            if f.name.trimmed.isEmpty { issues.append(.error(ctx, "missing name")) }
            if f.story.trimmed.isEmpty { issues.append(.error(ctx, "missing story")) }
            // A successfully decoded date is already parsed; sanity-check the year.
            let year = calendar.component(.year, from: f.date)
            if year < 2000 {
                issues.append(.error(ctx, "date did not parse to a sensible year (\(year))"))
            }
        }
        return issues
    }

    static func validateStories(_ stories: [StorySymbol]) -> [ValidationIssue] {
        var issues = checkUniqueIDs(stories.map(\.id), context: "stories")
        for s in stories {
            let ctx = "story '\(s.id)'"
            if s.title.trimmed.isEmpty { issues.append(.error(ctx, "missing title")) }
            if s.story.trimmed.isEmpty { issues.append(.error(ctx, "missing story body")) }
            if s.symbolMeaning.trimmed.isEmpty { issues.append(.error(ctx, "missing symbol meaning")) }
            if s.takeaway.trimmed.isEmpty { issues.append(.warning(ctx, "missing takeaway")) }
        }
        return issues
    }

    static func validateShlokas(_ shlokas: [ShlokaOfDay]) -> [ValidationIssue] {
        var issues = checkUniqueIDs(shlokas.map(\.id), context: "shlokas")
        for s in shlokas {
            let ctx = "shloka '\(s.id)'"
            if s.transliteration.trimmed.isEmpty { issues.append(.error(ctx, "missing transliteration")) }
            if s.translation.trimmed.isEmpty { issues.append(.error(ctx, "missing translation")) }
            if s.meaning.trimmed.isEmpty { issues.append(.error(ctx, "missing meaning")) }
            if s.deepLinkTarget.trimmed.isEmpty { issues.append(.error(ctx, "missing deepLinkTarget")) }
            if let key = s.dateKey, !isValidMonthDay(key) {
                issues.append(.error(ctx, "dateKey '\(key)' is not MM-dd"))
            }
        }
        return issues
    }

    static func validateAchievements(_ achievements: [Achievement]) -> [ValidationIssue] {
        var issues = checkUniqueIDs(achievements.map(\.id), context: "achievements")
        for a in achievements {
            let ctx = "achievement '\(a.id)'"
            if a.title.trimmed.isEmpty { issues.append(.error(ctx, "missing title")) }
            if a.target <= 0 { issues.append(.error(ctx, "requirement target must be > 0")) }
        }
        return issues
    }

    // MARK: - Forbidden term scan (user-facing labels)

    static func scanForbiddenTerms(
        mantras: [Mantra],
        lessons: [Lesson],
        festivals: [Festival],
        stories: [StorySymbol],
        shlokas: [ShlokaOfDay],
        achievements: [Achievement]
    ) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []

        func check(_ label: String, _ context: String) {
            for term in forbiddenTerms(in: label) {
                issues.append(.error(context, "forbidden term '\(term)' in label: \"\(label)\""))
            }
        }

        // Scan short, user-facing *labels* (titles, taglines, CTAs) — not long
        // educational body text, per ProductGuardrails §3.
        for m in mantras { check(m.title, "mantra '\(m.id)'") }
        for l in lessons {
            check(l.title, "lesson '\(l.id)'"); check(l.subtitle, "lesson '\(l.id)'")
            for step in l.steps { check(step.prompt, "lesson '\(l.id)' step '\(step.id)'") }
        }
        for f in festivals {
            check(f.name, "festival '\(f.id)'"); check(f.tagline, "festival '\(f.id)'")
            for activity in f.activities { check(activity, "festival '\(f.id)' activity") }
        }
        for s in stories {
            check(s.title, "story '\(s.id)'"); check(s.summary, "story '\(s.id)'"); check(s.takeaway, "story '\(s.id)'")
        }
        for s in shlokas { check(s.translation, "shloka '\(s.id)'") }
        for a in achievements { check(a.title, "achievement '\(a.id)'"); check(a.detail, "achievement '\(a.id)'") }

        return issues
    }

    // MARK: - Raw JSON checks

    /// Returns the ids of objects in a raw JSON array that are missing the
    /// `isPremium` flag. Used to guarantee premium flags are authored, which a
    /// decoded model can't reveal (decoding would simply fail).
    static func idsMissingPremiumFlag(inJSON data: Data) -> [String] {
        guard let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        return array.compactMap { object in
            if object["isPremium"] == nil {
                return object["id"] as? String ?? "<unknown>"
            }
            return nil
        }
    }

    // MARK: - Helpers

    private static func checkUniqueIDs(_ ids: [String], context: String) -> [ValidationIssue] {
        var seen = Set<String>()
        var dupes = Set<String>()
        for id in ids where !seen.insert(id).inserted { dupes.insert(id) }
        return dupes.sorted().map { .error(context, "duplicate id '\($0)'") }
    }

    private static func isValidMonthDay(_ value: String) -> Bool {
        let parts = value.split(separator: "-")
        guard parts.count == 2,
              let month = Int(parts[0]), let day = Int(parts[1]),
              (1...12).contains(month), (1...31).contains(day) else { return false }
        return parts[0].count == 2 && parts[1].count == 2
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
