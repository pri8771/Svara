import SwiftUI

/// First-run introduction to what Svara is — three warm pages, then in.
struct OnboardingView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var page = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            systemImage: "sun.and.horizon.fill",
            title: "Three minutes a day",
            message: "Start mornings with a mantra, end evenings with calm. Tiny daily practices, rooted in Hindu tradition.",
            gradient: SvaraTheme.Gradients.dawn
        ),
        OnboardingPage(
            systemImage: "graduationcap.fill",
            title: "Learn, the joyful way",
            message: "Bite-sized lessons teach you slokas and their meaning — like a language app for your spiritual side.",
            gradient: SvaraTheme.Gradients.saffron
        ),
        OnboardingPage(
            systemImage: "sparkles",
            title: "Never miss a moment",
            message: "Festivals, stories and symbols — understand the why behind the celebrations you grew up with.",
            gradient: SvaraTheme.Gradients.dusk
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                    OnboardingPageView(page: item)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            VStack(spacing: SvaraTheme.Spacing.md) {
                PrimaryButton(title: page == pages.count - 1 ? "Get Started" : "Continue") {
                    if page < pages.count - 1 {
                        withAnimation { page += 1 }
                    } else {
                        env.completeOnboarding()
                    }
                }
                Button("Skip") { env.completeOnboarding() }
                    .font(.svaraCallout)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
            }
            .padding(.horizontal, SvaraTheme.Spacing.screenMargin)
            .padding(.bottom, SvaraTheme.Spacing.xl)
        }
        .svaraScreenBackground()
    }
}

private struct OnboardingPage {
    let systemImage: String
    let title: String
    let message: String
    let gradient: LinearGradient
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: SvaraTheme.Spacing.xl) {
            Spacer()
            ZStack {
                Circle()
                    .fill(page.gradient)
                    .frame(width: 180, height: 180)
                    .shadow(color: SvaraTheme.Palette.saffronDeep.opacity(0.3), radius: 24, y: 12)
                Image(systemName: page.systemImage)
                    .font(.system(size: 72))
                    .foregroundStyle(.white)
            }
            VStack(spacing: SvaraTheme.Spacing.md) {
                Text(page.title)
                    .font(.svaraDisplay)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)
                Text(page.message)
                    .font(.svaraBody)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
                    .padding(.horizontal, SvaraTheme.Spacing.xl)
            }
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView().environment(AppEnvironment.preview())
}
