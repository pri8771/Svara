import Foundation

/// Canonical external URLs for Svara, in one place so the in-app links, the App
/// Store metadata and the hosted pages never drift apart.
///
/// The legal/support pages live in this repo under `docs/` and are served via
/// GitHub Pages (Settings → Pages → Deploy from branch → `/docs`). Keep these in
/// sync with `AppStore/metadata.md`.
enum SvaraLinks {
    static let privacyPolicy = URL(string: "https://pri8771.github.io/Svara/privacy.html")!
    static let termsOfService = URL(string: "https://pri8771.github.io/Svara/terms.html")!
    static let support = URL(string: "mailto:priyansh.chordia@gmail.com")!
    static let website = URL(string: "https://pri8771.github.io/Svara/")!
}
