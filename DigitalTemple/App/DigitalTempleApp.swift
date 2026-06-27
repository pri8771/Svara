import SwiftUI
import SwiftData

/// "My Mandir" — a sacred relationship system for Hindu life.
///
/// The app is fully offline: a single SwiftData store on the device, seeded
/// once from bundled JSON. No network calls are made anywhere.
@main
struct DigitalTempleApp: App {
    /// The shared local store holding every sacred object.
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: DigitalMandir.self,
                DevotionalIdentity.self,
                Devata.self,
                Sankalp.self,
                Reflection.self,
                Memory.self,
                SacredDateEntry.self,
                MandirReturn.self
            )
        } catch {
            fatalError("Could not create the local mandir store: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modelContainer(modelContainer)
                .task {
                    // Seed devatas and sacred dates once, on first launch.
                    // Hop to the main actor: the store's main context and the
                    // (main-actor) SeedLoader must run there.
                    await MainActor.run {
                        SeedLoader.seedIfNeeded(context: modelContainer.mainContext)
                    }
                }
        }
    }
}
