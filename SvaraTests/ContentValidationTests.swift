import XCTest
@testable import Svara

final class ContentValidationTests: XCTestCase {

    private var provider: SeedContentProvider!

    override func setUp() {
        super.setUp()
        provider = SeedContentProvider(bundle: .main)
    }

    /// The shipped seed content must have zero validation errors.
    func testSeedContentHasNoErrors() {
        let issues = ContentValidation.validate(using: provider)
        let errors = issues.filter { $0.severity == .error }
        XCTAssertTrue(errors.isEmpty, "Unexpected seed validation errors:\n" + errors.map(\.description).joined(separator: "\n"))
    }

    func testRequiredFieldsDetectedWhenMissing() {
        let bad = [
            Mantra(id: "", title: "", sanskrit: "", transliteration: "",
                   translation: "", meaning: "", deity: "X", theme: .wisdom)
        ]
        let issues = ContentValidation.validateMantras(bad)
        XCTAssertFalse(issues.isEmpty)
        XCTAssertTrue(issues.contains { $0.message.contains("missing title") })
        XCTAssertTrue(issues.contains { $0.message.contains("missing translation") })
    }

    func testAchievementTargetMustBePositive() {
        let bad = [Achievement(id: "a", title: "T", detail: "d", systemImage: "x", requirement: .streakDays(0))]
        let issues = ContentValidation.validateAchievements(bad)
        XCTAssertTrue(issues.contains { $0.message.contains("target must be > 0") })
    }

    func testQuizStepOutOfRangeCorrectIndexDetected() {
        let lesson = Lesson(
            id: "l", title: "T", subtitle: "s", theme: .wisdom, level: 1,
            steps: [
                LessonStep(id: "s1", kind: .multipleChoice, prompt: "Q",
                           options: ["A", "B"], correctIndex: 5)
            ]
        )
        let issues = ContentValidation.validateLessons([lesson])
        XCTAssertTrue(issues.contains { $0.message.contains("correctIndex out of range") })
    }

    func testFestivalDateSanityCheck() {
        // A festival whose date defaulted to 1970 should be flagged.
        let festival = Festival(
            id: "f", name: "N", date: Date(timeIntervalSince1970: 0),
            tagline: "t", significance: "s", story: "story body",
            activities: [], theme: .prosperity
        )
        let issues = ContentValidation.validateFestivals([festival])
        XCTAssertTrue(issues.contains { $0.message.contains("sensible year") })
    }

    func testDuplicateIDsDetected() {
        let a = Achievement(id: "dup", title: "A", detail: "d", systemImage: "x", requirement: .totalPoints(10))
        let b = Achievement(id: "dup", title: "B", detail: "d", systemImage: "x", requirement: .totalPoints(20))
        let issues = ContentValidation.validateAchievements([a, b])
        XCTAssertTrue(issues.contains { $0.message.contains("duplicate id 'dup'") })
    }

    /// Premium flags must be authored in JSON (decoding can't reveal omission).
    func testPremiumFlagsPresentInBundledJSON() throws {
        for file in ["seed_lessons", "seed_stories"] {
            let data = try provider.data(forResource: file)
            let missing = ContentValidation.idsMissingPremiumFlag(inJSON: data)
            XCTAssertTrue(missing.isEmpty, "\(file).json missing isPremium for: \(missing)")
        }
    }

    func testShlokaDateKeyFormatValidated() {
        let good = ShlokaOfDay(id: "s1", transliteration: "t", translation: "x",
                               meaning: "m", theme: .wisdom, dateKey: "11-08",
                               deepLinkTarget: "today")
        let bad = ShlokaOfDay(id: "s2", transliteration: "t", translation: "x",
                              meaning: "m", theme: .wisdom, dateKey: "8-8",
                              deepLinkTarget: "today")
        XCTAssertTrue(ContentValidation.validateShlokas([good]).isEmpty)
        XCTAssertTrue(ContentValidation.validateShlokas([bad]).contains { $0.message.contains("is not MM-dd") })
    }
}
