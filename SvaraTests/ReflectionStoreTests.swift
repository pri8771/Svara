import XCTest
@testable import Svara

/// Covers local-only reflection persistence — and that it never touches a
/// Firestore/Firebase path.
final class ReflectionStoreTests: XCTestCase {

    private var tempURL: URL!
    private var store: ReflectionStore!

    override func setUp() {
        super.setUp()
        tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("reflections-\(UUID().uuidString).json")
        store = ReflectionStore(fileURL: tempURL)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempURL)
        super.tearDown()
    }

    func testSaveAndRetrieveByStoryId() throws {
        try store.save(ReflectionEntry(storyId: "story_a", text: "First thought"))
        try store.save(ReflectionEntry(storyId: "story_b", text: "Other story"))

        let a = store.entries(for: "story_a")
        XCTAssertEqual(a.count, 1)
        XCTAssertEqual(a.first?.text, "First thought")
        XCTAssertEqual(store.entries(for: "story_b").count, 1)
        XCTAssertTrue(store.entries(for: "story_missing").isEmpty)
    }

    func testMultipleReflectionsReturnedInChronologicalOrder() throws {
        let t0 = Date(timeIntervalSince1970: 1_000_000)
        // Save out of order; expect oldest-first on read.
        try store.save(ReflectionEntry(storyId: "s", text: "second", createdAt: t0.addingTimeInterval(60)))
        try store.save(ReflectionEntry(storyId: "s", text: "first", createdAt: t0))
        try store.save(ReflectionEntry(storyId: "s", text: "third", createdAt: t0.addingTimeInterval(120)))

        XCTAssertEqual(store.entries(for: "s").map(\.text), ["first", "second", "third"])
    }

    func testPersistsAcrossInstances() throws {
        try store.save(ReflectionEntry(storyId: "s", text: "kept"))
        let reopened = ReflectionStore(fileURL: tempURL)
        XCTAssertEqual(reopened.entries(for: "s").map(\.text), ["kept"])
    }

    func testStoragePathIsLocalAndNeverFirebase() throws {
        try store.save(ReflectionEntry(storyId: "s", text: "local only"))
        let path = store.storageURL.path.lowercased()
        XCTAssertFalse(path.contains("firestore"), "reflections must never be written to a Firestore path")
        XCTAssertFalse(path.contains("firebase"), "reflections must never be written to a Firebase path")
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.storageURL.path), "saved locally")
    }

    func testClearRemovesAll() throws {
        try store.save(ReflectionEntry(storyId: "s", text: "x"))
        store.clear()
        XCTAssertTrue(store.allEntries().isEmpty)
    }

    func testSaveReportsWriteFailure() {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("reflection-directory-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directoryURL) }
        let unwritableStore = ReflectionStore(fileURL: directoryURL)

        XCTAssertThrowsError(
            try unwritableStore.save(ReflectionEntry(storyId: "s", text: "keep this"))
        )
    }
}
