import XCTest
@testable import Svara

/// LB-2: the app must open straight into content with **no auth wall** — a
/// local guest is established automatically, and sign-in is optional.
@MainActor
final class AuthFlowTests: XCTestCase {

    private func makeEnv(suite: String) -> AppEnvironment {
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let kv = UserDefaultsStore(defaults: defaults)
        return AppEnvironment(
            auth: MockAuthService(store: kv),
            content: LocalContentRepository(),
            progress: LocalProgressService(store: kv),
            notifications: LocalNotificationService(),
            store: StoreService(),
            kvStore: kv
        )
    }

    func testBootstrapEstablishesGuestWhenNoSession() async {
        let env = makeEnv(suite: "svara.test.auth.fresh")
        await env.bootstrap()
        XCTAssertTrue(env.isAuthenticated, "App should be usable immediately, no auth wall.")
        XCTAssertTrue(env.profile.isGuest, "A fresh launch should land on a local guest profile.")
    }

    func testGuestVersusSignedInProfile() {
        XCTAssertTrue(UserProfile.guest().isGuest)
        XCTAssertTrue(UserProfile(displayName: "Friend").isGuest, "No email ⇒ guest.")
        XCTAssertFalse(UserProfile(displayName: "Ananya", email: "a@b.com").isGuest)
    }

    func testSignOutReturnsToGuestNotAWall() async {
        let env = makeEnv(suite: "svara.test.auth.signout")
        try? await env.signIn(email: "ananya@example.com", password: "secret")
        XCTAssertFalse(env.profile.isGuest)
        await env.signOut()
        XCTAssertTrue(env.isAuthenticated, "Sign-out drops to guest, never an auth wall.")
        XCTAssertTrue(env.profile.isGuest)
    }
}
