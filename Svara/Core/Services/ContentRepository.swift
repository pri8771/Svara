import Foundation

/// Supplies all devotional content (mantras, practices, lessons, festivals,
/// stories, achievements). Local seed data in MVP; Firestore-backed later.
protocol ContentRepository {
    func mantras() async -> [Mantra]
    func dailyPractices() async -> [DailyPractice]
    func lessons() async -> [Lesson]
    func festivals() async -> [Festival]
    func stories() async -> [StorySymbol]
    func achievements() async -> [Achievement]

    func mantra(id: String) async -> Mantra?
}

/// Serves the bundled `SeedContent`. Async to match the eventual remote
/// implementation so call sites never change.
final class LocalContentRepository: ContentRepository {
    func mantras() async -> [Mantra] { SeedContent.mantras }
    func dailyPractices() async -> [DailyPractice] { SeedContent.dailyPractices }
    func lessons() async -> [Lesson] { SeedContent.lessons }
    func festivals() async -> [Festival] { SeedContent.festivals }
    func stories() async -> [StorySymbol] { SeedContent.stories }
    func achievements() async -> [Achievement] { SeedContent.achievements }

    func mantra(id: String) async -> Mantra? {
        SeedContent.mantras.first { $0.id == id }
    }
}

// MARK: - Firestore production seam
//
// final class FirestoreContentRepository: ContentRepository {
//     private let db = Firestore.firestore()
//     func mantras() async -> [Mantra] {
//         (try? await db.collection("mantras").getDocuments()
//             .documents.compactMap { try $0.data(as: Mantra.self) }) ?? []
//     }
//     ... mirror for each collection, falling back to SeedContent on failure ...
// }
