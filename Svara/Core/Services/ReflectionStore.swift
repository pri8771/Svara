import Foundation

/// Persists the user's private story reflections to a local JSON file in the
/// app's Documents directory.
///
/// Reflections are intentionally local-only and never synced. There is no
/// Firestore, CloudKit, or iCloud path here — by design, reflection text never
/// leaves the device.
final class ReflectionStore {
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    /// - Parameter fileURL: override the storage location (used by tests). When
    ///   `nil`, defaults to `Documents/reflections.json`.
    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let documents = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
            self.fileURL = documents.appendingPathComponent("reflections.json")
        }
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder.dateDecodingStrategy = .iso8601
    }

    /// The local file reflections are stored in (exposed for tests/inspection).
    var storageURL: URL { fileURL }

    /// Appends a reflection and persists.
    func save(_ entry: ReflectionEntry) {
        var entries = allEntries()
        entries.append(entry)
        persist(entries)
    }

    /// All reflections for a story, oldest first.
    func entries(for storyId: String) -> [ReflectionEntry] {
        allEntries()
            .filter { $0.storyId == storyId }
            .sorted { $0.createdAt < $1.createdAt }
    }

    /// Every stored reflection, oldest first.
    func allEntries() -> [ReflectionEntry] {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? decoder.decode([ReflectionEntry].self, from: data) else {
            return []
        }
        return decoded.sorted { $0.createdAt < $1.createdAt }
    }

    /// Removes all reflections (used by sign-out / tests).
    func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }

    private func persist(_ entries: [ReflectionEntry]) {
        guard let data = try? encoder.encode(entries) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }
}
