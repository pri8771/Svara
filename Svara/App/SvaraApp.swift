import SwiftUI
import UIKit

@main
struct SvaraApp: App {
    @State private var environment = AppEnvironment.live()

    init() {
        // Firebase production seam — uncomment once GoogleService-Info.plist is added:
        // FirebaseApp.configure()
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
                .task { await environment.bootstrap() }
                .tint(SvaraTheme.Colors.primary)
        }
    }

    private func configureAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(SvaraTheme.Colors.surface)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
