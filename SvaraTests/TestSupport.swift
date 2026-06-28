import Foundation
@testable import Svara

/// An in-memory `KeyValueStore` for deterministic unit tests.
final class InMemoryStore: KeyValueStore {
    private var storage: [String: Data] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = storage[key] else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    func save<T: Encodable>(_ value: T, forKey key: String) {
        storage[key] = try? encoder.encode(value)
    }

    func remove(forKey key: String) {
        storage[key] = nil
    }
}

/// Test helpers for building lessons/steps quickly.
enum LessonFactory {
    static func step(
        _ id: String,
        kind: LessonStep.Kind,
        options: [String] = [],
        correctIndex: Int? = nil,
        acceptedAnswers: [String] = [],
        syllables: [String] = [],
        hint: String? = nil
    ) -> LessonStep {
        LessonStep(id: id, kind: kind, prompt: id, detail: nil,
                   options: options, correctIndex: correctIndex,
                   acceptedAnswers: acceptedAnswers, syllables: syllables, hint: hint)
    }

    static func lesson(
        _ id: String,
        level: Int,
        pathDay: Int? = nil,
        mantraID: String? = nil,
        isPremium: Bool = false,
        steps: [LessonStep] = []
    ) -> Lesson {
        Lesson(id: id, title: id, subtitle: "", theme: .wisdom, level: level,
               mantraID: mantraID, steps: steps.isEmpty ? [step("\(id).s1", kind: .intro)] : steps,
               isPremium: isPremium, pathDay: pathDay)
    }
}
