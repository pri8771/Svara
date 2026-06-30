import Foundation

/// Loads Svara's seed content from bundled JSON (`Resources/SeedData/*.json`),
/// falling back to the in-code `SeedContent` arrays if a file is missing or
/// fails to decode. This keeps previews, tests and offline use rock-solid while
/// making JSON the authoring source of truth.
///
/// Daily practices remain in-code (no JSON file) by design.
final class SeedContentProvider {
    static let shared = SeedContentProvider()

    private let bundle: Bundle
    let decoder: JSONDecoder

    init(bundle: Bundle = .main) {
        self.bundle = bundle
        self.decoder = SeedContentProvider.makeDecoder()
        #if DEBUG
        logValidationIssues()
        #endif
    }

    /// A decoder configured to parse festival dates from "yyyy-MM-dd" (with an
    /// ISO-8601 fallback).
    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        let dayFormatter = DateFormatter()
        dayFormatter.calendar = Calendar(identifier: .gregorian)
        dayFormatter.locale = Locale(identifier: "en_US_POSIX")
        dayFormatter.timeZone = TimeZone(identifier: "UTC")
        dayFormatter.dateFormat = "yyyy-MM-dd"

        let iso = ISO8601DateFormatter()

        decoder.dateDecodingStrategy = .custom { dec in
            let container = try dec.singleValueContainer()
            let raw = try container.decode(String.self)
            if let date = dayFormatter.date(from: raw) {
                // Anchor date-only ("yyyy-MM-dd") values at 12:00 UTC, not
                // midnight. Midnight UTC falls on the *previous* calendar day
                // for any user west of UTC (e.g. all of the Americas), which
                // would shift every festival a day earlier and break the
                // countdown. Noon UTC keeps the intended calendar day stable
                // across every real-world time zone (UTC-11 … UTC+12).
                return date.addingTimeInterval(12 * 60 * 60)
            }
            if let date = iso.date(from: raw) { return date }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unparseable date '\(raw)'. Expected yyyy-MM-dd or ISO-8601."
            )
        }
        return decoder
    }

    enum SeedError: LocalizedError {
        case missingFile(String)
        var errorDescription: String? {
            switch self {
            case .missingFile(let name): return "Seed file \(name).json not found in bundle."
            }
        }
    }

    /// Raw data for a seed file (used by validation/tests). Throws if missing.
    func data(forResource file: String) throws -> Data {
        guard let url = bundle.url(forResource: file, withExtension: "json", subdirectory: "SeedData")
                ?? bundle.url(forResource: file, withExtension: "json") else {
            throw SeedError.missingFile(file)
        }
        return try Data(contentsOf: url)
    }

    /// Decodes an array of `T` from a named seed file. Throws on any failure.
    func decode<T: Decodable>(_ type: [T].Type, from file: String) throws -> [T] {
        let data = try data(forResource: file)
        return try decoder.decode([T].self, from: data)
    }

    private func load<T: Decodable>(_ file: String, fallback: @autoclosure () -> [T]) -> [T] {
        do {
            return try decode([T].self, from: file)
        } catch {
            #if DEBUG
            print("⚠️ SeedContentProvider: '\(file).json' failed (\(error.localizedDescription)). Using in-code fallback.")
            #endif
            return fallback()
        }
    }

    // MARK: - Content (lazily loaded once)

    private(set) lazy var mantras: [Mantra] = load("seed_mantras", fallback: SeedContent.mantras)
    private(set) lazy var lessons: [Lesson] = load("seed_lessons", fallback: SeedContent.lessons)
    private(set) lazy var festivals: [Festival] = load("seed_festivals", fallback: SeedContent.festivals)
    private(set) lazy var stories: [StorySymbol] = load("seed_stories", fallback: SeedContent.stories)
    private(set) lazy var shlokas: [ShlokaOfDay] = load("seed_shlokas", fallback: SeedContent.shlokas)
    private(set) lazy var achievements: [Achievement] = load("seed_achievements", fallback: SeedContent.achievements)

    /// Daily practices are intentionally in-code (no JSON file).
    var dailyPractices: [DailyPractice] { SeedContent.dailyPractices }

    #if DEBUG
    private func logValidationIssues() {
        let issues = ContentValidation.validate(
            mantras: load("seed_mantras", fallback: SeedContent.mantras),
            lessons: load("seed_lessons", fallback: SeedContent.lessons),
            festivals: load("seed_festivals", fallback: SeedContent.festivals),
            stories: load("seed_stories", fallback: SeedContent.stories),
            shlokas: load("seed_shlokas", fallback: SeedContent.shlokas),
            achievements: load("seed_achievements", fallback: SeedContent.achievements)
        )
        for issue in issues {
            print("⚠️ ContentValidation [\(issue.severity)] \(issue.context): \(issue.message)")
        }
    }
    #endif
}
