import Foundation

/// Owns the local profile session. This is not authentication: Svara 1.0 has
/// no account, credentials, or server identity.
protocol ProfileSessionService {
    func restoreProfile() async -> UserProfile?
    func createProfileIfNeeded() async -> UserProfile
}

/// Production local-profile persistence backed by `KeyValueStore`.
final class LocalProfileSessionService: ProfileSessionService {
    private let store: KeyValueStore

    init(store: KeyValueStore) {
        self.store = store
    }

    func restoreProfile() async -> UserProfile? {
        store.load(UserProfile.self, forKey: StorageKey.userProfile)
    }

    func createProfileIfNeeded() async -> UserProfile {
        if let existing = store.load(UserProfile.self, forKey: StorageKey.userProfile) {
            return existing
        }
        let profile = UserProfile(displayName: "Friend")
        store.save(profile, forKey: StorageKey.userProfile)
        return profile
    }
}
