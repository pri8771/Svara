import SwiftUI
import SwiftData

/// Container for the five-step onboarding journey. Steps are presented one at a
/// time over the shared sacred background, with a quiet progress indicator.
struct OnboardingFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(AppConstants.DefaultsKey.hasCompletedOnboarding)
    private var hasCompletedOnboarding: Bool = false

    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            ScreenBackground()

            VStack(spacing: 0) {
                if viewModel.step != .welcome {
                    OnboardingProgressBar(step: viewModel.step)
                        .padding(.top, 8)
                        .screenPadding()
                }

                Group {
                    switch viewModel.step {
                    case .welcome:
                        WelcomeView(viewModel: viewModel)
                    case .intention:
                        IntentionSelectionView(viewModel: viewModel)
                    case .nameMandir:
                        NameMandirView(viewModel: viewModel)
                    case .chooseDevata:
                        ChooseDevataView(viewModel: viewModel)
                    case .firstSankalp:
                        CreateSankalpView(viewModel: viewModel, onFinish: complete)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.step)
    }

    private func complete(createSankalp: Bool) {
        viewModel.complete(
            createSankalp: createSankalp,
            context: modelContext,
            hasCompletedOnboarding: &hasCompletedOnboarding
        )
    }
}

/// A row of small lamps marking progress through the journey.
private struct OnboardingProgressBar: View {
    let step: OnboardingStep

    var body: some View {
        HStack(spacing: 8) {
            ForEach(OnboardingStep.allCases, id: \.rawValue) { s in
                Capsule()
                    .fill(s.rawValue <= step.rawValue ? Theme.Palette.accent : Theme.Palette.hairline)
                    .frame(height: 4)
            }
        }
        .accessibilityLabel("Step \(step.rawValue + 1) of \(OnboardingStep.allCases.count)")
    }
}

#Preview {
    OnboardingFlowView()
        .modelContainer(for: [
            DigitalMandir.self, DevotionalIdentity.self, Devata.self,
            Sankalp.self, Reflection.self, Memory.self, SacredDateEntry.self
        ], inMemory: true)
}
