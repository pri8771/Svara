import Foundation

// MARK: - Firebase production seam
//
// Svara is designed so Firebase Auth + Firestore can be dropped in without
// touching any feature code — every screen depends only on the `AuthService`
// and `ContentRepository` protocols.
//
// To enable Firebase:
//   1. Add the `firebase-ios-sdk` Swift Package (FirebaseAuth, FirebaseFirestore).
//   2. Drop `GoogleService-Info.plist` into the app target (git-ignored).
//   3. Call `FirebaseApp.configure()` in `SvaraApp.init`.
//   4. Uncomment the implementation below and register this service in
//      `AppEnvironment` instead of `MockAuthService`.
//
// The stub below conforms to `AuthService` and compiles without the SDK so the
// project always builds; it simply reports `.notConfigured` until wired up.

final class FirebaseAuthService: AuthService {

    func restoreSession() async -> UserProfile? {
        // return Auth.auth().currentUser.map(UserProfile.init(firebaseUser:))
        nil
    }

    func signInAnonymously() async throws -> UserProfile {
        // let result = try await Auth.auth().signInAnonymously()
        // return UserProfile(firebaseUser: result.user)
        throw AuthError.notConfigured
    }

    func signIn(email: String, password: String) async throws -> UserProfile {
        // let result = try await Auth.auth().signIn(withEmail: email, password: password)
        // return UserProfile(firebaseUser: result.user)
        throw AuthError.notConfigured
    }

    func register(displayName: String, email: String, password: String) async throws -> UserProfile {
        // let result = try await Auth.auth().createUser(withEmail: email, password: password)
        // let change = result.user.createProfileChangeRequest()
        // change.displayName = displayName
        // try await change.commitChanges()
        // return UserProfile(firebaseUser: result.user)
        throw AuthError.notConfigured
    }

    func signOut() async throws {
        // try Auth.auth().signOut()
        throw AuthError.notConfigured
    }
}
