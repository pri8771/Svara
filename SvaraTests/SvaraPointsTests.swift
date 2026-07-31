import XCTest
@testable import Svara

@MainActor
final class SvaraPointsTests: XCTestCase {
    func testAuthoredPointsMilestonesAreUsefulAndNonCircular() {
        let milestones = SeedContentProvider.shared.achievements
            .filter(\.isPointsMilestone)
            .sorted { $0.target < $1.target }

        XCTAssertEqual(milestones.map(\.target), [100, 250, 500])
        XCTAssertTrue(milestones.allSatisfy { $0.bonusPoints == 0 })
    }

    func testProfileSelectsTheNextUnreachedPointsMilestone() {
        let model = ProfileViewModel(achievements: SeedContentProvider.shared.achievements)
        var profile = UserProfile.guest()

        XCTAssertEqual(model.nextPointsMilestone(profile: profile)?.target, 100)
        profile.totalPoints = 100
        XCTAssertEqual(model.nextPointsMilestone(profile: profile)?.target, 250)
        profile.totalPoints = 500
        XCTAssertNil(model.nextPointsMilestone(profile: profile))
    }

    func testRequirementLabelsExplainEveryAchievementRule() {
        XCTAssertEqual(
            Achievement(
                id: "p", title: "P", detail: "D", systemImage: "sparkles",
                requirement: .totalPoints(100)
            ).requirementLabel,
            "100 points"
        )
    }
}
