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

    func testSaveAndRetrieveByStoryId() {
        store.save(ReflectionEntry(storyId: "story_a", text: "First thought"))
        store.save(ReflectionEntry(storyId: "story_b", text: "Other story"))

        let a = store.entries(for: "story_a")
        XCTAssertEqual(a.count, 1)
        XCTAssertEqual(a.first?.text, "First thought")
        XCTAssertEqual(store.entries(for: "story_b").count, 1)
        XCTAssertTrue(store.entries(for: "story_missing").isEmpty)
    }

    func testMultipleReflectionsReturnedInChronologicalOrder() {
        let t0 = Date(timeIntervalSince1970: 1_000_000)
        // Save out of order; expect oldest-first on read.
        store.save(ReflectionEntry(storyId: "s", text: "second", createdAt: t0.addingTimeInterval(60)))
        store.save(ReflectionEntry(storyId: "s", text: "first", createdAt: t0))
        store.save(ReflectionEntry(storyId: "s", text: "third", createdAt: t0.addingTimeInterval(120)))

        XCTAssertEqual(store.entries(for: "s").map(\.text), ["first", "second", "third"])
    }

    func testPersistsAcrossInstances() {
        store.save(ReflectionEntry(storyId: "s", text: "kept"))
        let reopened = ReflectionStore(fileURL: tempURL)
        XCTAssertEqual(reopened.entries(for: "s").map(\.text), ["kept"])
    }

    func testStoragePathIsLocalAndNeverFirebase() {
        store.save(ReflectionEntry(storyId: "s", text: "local only"))
        let path = store.storageURL.path.lowercased()
        XCTAssertFalse(path.contains("firestore"), "reflections must never be written to a Firestore path")
        XCTAssertFalse(path.contains("firebase"), "reflections must never be written to a Firebase path")
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.storageURL.path), "saved locally")
    }

    func testClearRemovesAll() {
        store.save(ReflectionEntry(storyId: "s", text: "x"))
        store.clear()
        XCTAssertTrue(store.allEntries().isEmpty)
    }
}
