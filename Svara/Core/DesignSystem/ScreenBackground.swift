import SwiftUI

/// Applies Svara's warm cream background to a screen.
struct ScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(SvaraTheme.Colors.background.ignoresSafeArea())
    }
}

extension View {
    func svaraScreenBackground() -> some View {
        modifier(ScreenBackground())
    }
}

/// A soft decorative header band used at the top of scrollable screens.
struct GreetingHeader: View {
    let eyebrow: String
    let title: String
    var trailing: AnyView? = nil

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(eyebrow)
                    .svaraEyebrow()
                Text(title)
                    .font(.svaraDisplay)
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)
            }
            Spacer(minLength: 0)
            if let trailing { trailing }
        }
    }
}
