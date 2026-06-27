import SwiftUI
import SwiftData

/// Decides what the person sees on launch: the onboarding journey if they have
/// not yet built their mandir, otherwise the mandir itself.
///
/// The decision is driven by the presence of a `DigitalMandir` in the store
/// (the durable source of truth), mirrored by a UserDefaults flag for a calm
/// first frame.
struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var mandirs: [DigitalMandir]

    @AppStorage(AppConstants.DefaultsKey.hasCompletedOnboarding)
    private var hasCompletedOnboarding: Bool = false

    var body: some View {
        Group {
            if let mandir = mandirs.first, hasCompletedOnboarding {
                MandirHomeView(mandir: mandir)
            } else {
                OnboardingFlowView()
            }
        }
        .tint(Theme.Palette.accent)
        .animation(.easeInOut(duration: 0.4), value: hasCompletedOnboarding)
    }
}

#Preview {
    AppRootView()
        .modelContainer(for: [
            DigitalMandir.self, DevotionalIdentity.self, Devata.self,
            Sankalp.self, Reflection.self, Memory.self, SacredDateEntry.self
        ], inMemory: true)
}
