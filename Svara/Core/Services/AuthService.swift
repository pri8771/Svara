import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case notConfigured
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "That email or password didn't match. Please try again."
        case .notConfigured: return "Sign-in isn't configured yet."
        case .unknown(let message): return message
        }
    }
}

/// Abstracts authentication so the app never depends on a concrete backend.
/// `MockAuthService` is used in MVP/dev; `FirebaseAuthService` is the
/// production seam (see `FirebaseAuthService.swift`).
protocol AuthService {
    /// Restores a previously signed-in user, if any.
    func restoreSession() async -> UserProfile?
    /// Signs in as an anonymous guest (used for "try it" / first run).
    func signInAnonymously() async throws -> UserProfile
    func signIn(email: String, password: String) async throws -> UserProfile
    func register(displayName: String, email: String, password: String) async throws -> UserProfile
    func signOut() async throws
}

/// A fully local auth implementation backed by `KeyValueStore`. No network,
/// suitable for MVP, previews and offline use.
final class MockAuthService: AuthService {
    private let store: KeyValueStore

    init(store: KeyValueStore) {
        self.store = store
    }

    func restoreSession() async -> UserProfile? {
        store.load(UserProfile.self, forKey: StorageKey.userProfile)
    }

    func signInAnonymously() async throws -> UserProfile {
        if let existing = store.load(UserProfile.self, forKey: StorageKey.userProfile) {
            return existing
        }
        let profile = UserProfile(displayName: "Friend")
        store.save(profile, forKey: StorageKey.userProfile)
        return profile
    }

    func signIn(email: String, password: String) async throws -> UserProfile {
        guard email.contains("@"), password.count >= 4 else {
            throw AuthError.invalidCredentials
        }
        if var existing = store.load(UserProfile.self, forKey: StorageKey.userProfile) {
            existing.email = email
            store.save(existing, forKey: StorageKey.userProfile)
            return existing
        }
        let profile = UserProfile(
            displayName: email.components(separatedBy: "@").first?.capitalized ?? "Friend",
            email: email
        )
        store.save(profile, forKey: StorageKey.userProfile)
        return profile
    }

    func register(displayName: String, email: String, password: String) async throws -> UserProfile {
        guard email.contains("@"), password.count >= 4, !displayName.isEmpty else {
            throw AuthError.invalidCredentials
        }
        let profile = UserProfile(displayName: displayName, email: email)
        store.save(profile, forKey: StorageKey.userProfile)
        return profile
    }

    func signOut() async throws {
        store.remove(forKey: StorageKey.userProfile)
        store.remove(forKey: StorageKey.sessions)
    }
}
