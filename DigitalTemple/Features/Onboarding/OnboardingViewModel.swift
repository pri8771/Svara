import Foundation
import SwiftData
import Observation

/// The six gentle reasons a person might arrive ("Why are you here?"). Distinct
/// from the eight sankalp `IntentionType`s — this is about the person, not a
/// single vow — but each suggests a natural first intention.
enum OnboardingIntention: String, CaseIterable, Identifiable {
    case healing
    case gratitude
    case remembrance
    case beginning
    case protection
    case roots

    var id: String { rawValue }

    var title: String {
        switch self {
        case .healing: return "To seek healing"
        case .gratitude: return "To give thanks"
        case .remembrance: return "To remember someone"
        case .beginning: return "To begin again"
        case .protection: return "To feel held"
        case .roots: return "To stay close to my roots"
        }
    }

    var glyph: String {
        switch self {
        case .healing: return "🌿"
        case .gratitude: return "🙏"
        case .remembrance: return "🕯️"
        case .beginning: return "🌅"
        case .protection: return "🛡️"
        case .roots: return "🪷"
        }
    }

    /// The sankalp intention this reason naturally leads toward.
    var suggestedSankalpType: IntentionType {
        switch self {
        case .healing: return .healing
        case .gratitude: return .gratitude
        case .remembrance: return .grief
        case .beginning: return .renewal
        case .protection: return .protection
        case .roots: return .reconnection
        }
    }
}

/// The steps of the onboarding journey.
enum OnboardingStep: Int, CaseIterable {
    case welcome        // 1
    case intention      // 2
    case nameMandir     // 3
    case chooseDevata   // 4
    case firstSankalp   // 5
}

/// Holds the in-progress onboarding selections and commits them to the store
/// when the journey completes. Pure state + one `complete` action — no view
/// concerns.
@MainActor
@Observable
final class OnboardingViewModel {
    // Navigation
    var step: OnboardingStep = .welcome

    // Step 2 — intention
    var selectedIntention: OnboardingIntention?

    // Step 3 — naming
    var mandirName: String = ""
    var displayName: String = ""

    // Step 4 — devatas (multi-select, by Devata.id)
    var chosenDevataIds: Set<UUID> = []

    // Step 5 — optional first sankalp
    var sankalpIntentionText: String = ""
    var sankalpForWhom: String = ""
    var sankalpType: IntentionType = .gratitude

    private let analytics: AnalyticsService

    init(analytics: AnalyticsService = .shared) {
        self.analytics = analytics
        analytics.log(.onboardingStarted)
    }

    // MARK: Navigation helpers

    func advance() {
        guard let next = OnboardingStep(rawValue: step.rawValue + 1) else { return }
        step = next
    }

    func goBack() {
        guard let prev = OnboardingStep(rawValue: step.rawValue - 1) else { return }
        step = prev
    }

    /// Pre-fill the suggested sankalp type when the person picks an intention.
    func selectIntention(_ intention: OnboardingIntention) {
        selectedIntention = intention
        sankalpType = intention.suggestedSankalpType
        analytics.log(.onboardingIntentionSelected(intention: intention.rawValue))
    }

    func toggleDevata(_ id: UUID) {
        if chosenDevataIds.contains(id) {
            chosenDevataIds.remove(id)
        } else {
            chosenDevataIds.insert(id)
        }
    }

    var canName: Bool { !mandirName.trimmingCharacters(in: .whitespaces).isEmpty }
    var hasChosenDevata: Bool { !chosenDevataIds.isEmpty }
    var hasSankalpText: Bool {
        !sankalpIntentionText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: Commit

    /// Build the mandir, identity, chosen devatas, and (optionally) the first
    /// sankalp, then mark onboarding complete.
    func complete(createSankalp: Bool, context: ModelContext, hasCompletedOnboarding: inout Bool) {
        let repo = MandirRepository(context: context)

        let primaryDevataId = chosenDevataIds.first
        let mandir = repo.createMandir(
            name: mandirName.trimmingCharacters(in: .whitespaces),
            primaryDevataId: primaryDevataId
        )

        repo.createIdentity(
            displayName: displayName.trimmingCharacters(in: .whitespaces),
            onboardingIntention: selectedIntention?.rawValue ?? "",
            traditionLeaning: nil,
            mandirId: mandir.id
        )
        analytics.log(.mandirNamed)

        // Mark chosen devatas as residing in the mandir.
        let allDevatas = repo.allDevatas()
        for devata in allDevatas where chosenDevataIds.contains(devata.id) {
            devata.isChosen = true
        }
        repo.save()
        analytics.log(.devatasChosen(count: chosenDevataIds.count))

        let madeSankalp = createSankalp && hasSankalpText
        if madeSankalp {
            let forWhom = sankalpForWhom.trimmingCharacters(in: .whitespaces)
            repo.createSankalp(
                intention: sankalpIntentionText.trimmingCharacters(in: .whitespaces),
                forWhom: forWhom.isEmpty ? nil : forWhom,
                type: sankalpType,
                devataId: primaryDevataId,
                dueDate: nil,
                mandirId: mandir.id
            )
            analytics.log(.sankalpCreated(type: sankalpType.rawValue))
        }

        analytics.log(.onboardingCompleted(createdSankalp: madeSankalp))
        hasCompletedOnboarding = true
    }
}
