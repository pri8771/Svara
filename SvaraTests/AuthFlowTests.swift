import XCTest
@testable import Svara

/// LB-2: the app must open straight into content with **no auth wall** — a
/// local guest is established automatically, and sign-in is optional.
@MainActor
final class AuthFlowTests: XCTestCase {

    private func makeEnv(suite: String, reset: Bool = true) -> AppEnvironment {
        let defaults = UserDefaults(suiteName: suite)!
        if reset {
            defaults.removePersistentDomain(forName: suite)
        }
        let kv = UserDefaultsStore(defaults: defaults)
        return AppEnvironment(
            profileSession: LocalProfileSessionService(store: kv),
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

    func testLocalProfileHasNoAccount() {
        XCTAssertTrue(UserProfile.guest().isGuest)
        XCTAssertTrue(UserProfile(displayName: "Friend").isGuest, "No email ⇒ guest.")
    }

    func testDisplayNameUpdatePersistsWithoutCreatingAccount() {
        let env = makeEnv(suite: "svara.test.profile.name")
        env.updateDisplayName("  Ananya  ")
        XCTAssertEqual(env.profile.displayName, "Ananya")
        XCTAssertNil(env.profile.email)
    }

    func testLegacyMockAccountAndPremiumFlagAreCleared() async {
        let suite = "svara.test.auth.migration"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let kv = UserDefaultsStore(defaults: defaults)
        kv.save(
            UserProfile(
                displayName: "Ananya",
                email: "ananya@example.com",
                isPremium: true
            ),
            forKey: StorageKey.userProfile
        )

        let env = makeEnv(suite: suite, reset: false)
        await env.bootstrap()

        XCTAssertNil(env.profile.email)
        XCTAssertFalse(env.profile.isPremium)
        XCTAssertFalse(env.isPremium, "Only a current StoreKit entitlement unlocks Plus.")
    }
}
