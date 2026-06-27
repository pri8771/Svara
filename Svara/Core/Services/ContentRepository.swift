import Foundation

/// Supplies all devotional content (mantras, practices, lessons, festivals,
/// stories, shlokas, achievements). Local seed data in MVP; Firestore-backed
/// later. Content is loaded from bundled JSON via `SeedContentProvider`.
protocol ContentRepository {
    func mantras() async -> [Mantra]
    func dailyPractices() async -> [DailyPractice]
    func lessons() async -> [Lesson]
    func festivals() async -> [Festival]
    func stories() async -> [StorySymbol]
    func shlokas() async -> [ShlokaOfDay]
    func achievements() async -> [Achievement]

    func mantra(id: String) async -> Mantra?
    /// The deterministic "shloka of the day" for the given date.
    func shlokaOfDay(for date: Date) async -> ShlokaOfDay?
}

/// Serves bundled JSON seed content (with in-code fallback) via
/// `SeedContentProvider`. Async to match the eventual remote implementation so
/// call sites never change.
final class LocalContentRepository: ContentRepository {
    private let provider: SeedContentProvider

    init(provider: SeedContentProvider = .shared) {
        self.provider = provider
    }

    func mantras() async -> [Mantra] { provider.mantras }
    func dailyPractices() async -> [DailyPractice] { provider.dailyPractices }
    func lessons() async -> [Lesson] { provider.lessons }
    func festivals() async -> [Festival] { provider.festivals }
    func stories() async -> [StorySymbol] { provider.stories }
    func shlokas() async -> [ShlokaOfDay] { provider.shlokas }
    func achievements() async -> [Achievement] { provider.achievements }

    func mantra(id: String) async -> Mantra? {
        provider.mantras.first { $0.id == id }
    }

    func shlokaOfDay(for date: Date) async -> ShlokaOfDay? {
        ShlokaSelector.shloka(for: date, from: provider.shlokas)
    }
}

// MARK: - Firestore production seam
//
// final class FirestoreContentRepository: ContentRepository {
//     private let db = Firestore.firestore()
//     func mantras() async -> [Mantra] {
//         (try? await db.collection("mantras").getDocuments()
//             .documents.compactMap { try $0.data(as: Mantra.self) }) ?? SeedContent.mantras
//     }
//     ... mirror for each collection, falling back to seed content on failure ...
//     // NOTE: private reflection text (DailyCheckIn.intention/.note) is NEVER
//     // written to Firestore in Phase 2A — see DailyCheckIn docs.
// }
