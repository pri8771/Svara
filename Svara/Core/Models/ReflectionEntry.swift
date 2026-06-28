import Foundation

/// A private reflection a user writes in response to a story's reflection prompt.
///
/// These are intentionally **local-only** and are never synced to Firestore,
/// CloudKit, or iCloud. Persisted as local JSON via `ReflectionStore`.
struct ReflectionEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let storyId: String
    let text: String
    let createdAt: Date

    init(id: UUID = UUID(), storyId: String, text: String, createdAt: Date = Date()) {
        self.id = id
        self.storyId = storyId
        self.text = text
        self.createdAt = createdAt
    }
}
