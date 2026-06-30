import Foundation

/// A tiny Codable-over-UserDefaults store. Swappable for Keychain/Firestore
/// later; kept behind this type so call sites never touch UserDefaults directly.
protocol KeyValueStore {
    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T?
    func save<T: Encodable>(_ value: T, forKey key: String)
    func remove(forKey key: String)
}

struct UserDefaultsStore: KeyValueStore {
    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
}

enum StorageKey {
    static let userProfile = "svara.userProfile"
    static let sessions = "svara.sessions"
    static let onboardingComplete = "svara.onboardingComplete"
    static let lessonProgress = "svara.lessonProgress"
}
