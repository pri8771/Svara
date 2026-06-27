import SwiftUI

extension View {
    /// Wrap a screen's content over the shared sacred background.
    func sacredScreen() -> some View {
        self.background(ScreenBackground())
    }

    /// Standard horizontal padding for screen content.
    func screenPadding() -> some View {
        self.padding(.horizontal, Theme.Metrics.screenPadding)
    }
}
