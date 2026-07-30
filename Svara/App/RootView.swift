import SwiftUI

/// Decides what to show at launch: onboarding → main app.
///
/// There is intentionally **no auth wall** — Svara is usable immediately as a
/// local profile ("no account required to start"). A profile is established by
/// `AppEnvironment.bootstrap()` and remains only on the device.
struct RootView: View {
    @Environment(AppEnvironment.self) private var env

    var body: some View {
        Group {
            if !env.hasCompletedOnboarding {
                OnboardingView()
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: env.hasCompletedOnboarding)
    }
}

#Preview("Onboarding") {
    let env = AppEnvironment.preview()
    env.hasCompletedOnboarding = false
    env.isAuthenticated = false
    return RootView().environment(env)
}

#Preview("Main") {
    RootView().environment(AppEnvironment.preview())
}
