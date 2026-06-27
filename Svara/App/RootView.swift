import SwiftUI

/// Decides what to show at launch: onboarding → auth → main app.
struct RootView: View {
    @Environment(AppEnvironment.self) private var env

    var body: some View {
        Group {
            if !env.hasCompletedOnboarding {
                OnboardingView()
                    .transition(.opacity)
            } else if !env.isAuthenticated {
                AuthView()
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: env.hasCompletedOnboarding)
        .animation(.easeInOut, value: env.isAuthenticated)
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
