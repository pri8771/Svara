import Foundation

/// Small, stable values used across the app. Kept tiny on purpose — most
/// content lives in seed JSON, not in code.
enum AppConstants {
    static let appName = "My Mandir"
    static let bundleIdentifier = "com.mymandir.digitaltemple"

    /// UserDefaults keys.
    enum DefaultsKey {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let hasSeededData = "hasSeededData"
    }

    /// Bundled seed resources (loaded once on first launch).
    enum SeedResource {
        static let devatas = "devatas"
        static let sacredDates = "sacredDates"
    }
}
