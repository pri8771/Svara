import XCTest
@testable import Svara

/// Covers festival activity completion: points awarded exactly once.
final class FestivalProgressTests: XCTestCase {

    private func makeService() -> LocalProgressService {
        LocalProgressService(store: InMemoryStore(), achievements: [])
    }

    private func festival(_ id: String) -> Festival {
        Festival(id: id, name: id, date: Date(), tagline: "t",
                 significance: "s", story: "story", activities: [], theme: .prosperity)
    }

    func testCompletingActivityAwardsPointsOnce() {
        let svc = makeService()
        let f = festival("festival.x")
        let (p1, _) = svc.completeFestivalActivity(f, points: 15, for: .guest())
        XCTAssertEqual(p1.totalPoints, 15)
        XCTAssertEqual(p1.observedFestivalIDs, ["festival.x"])

        let (p2, _) = svc.completeFestivalActivity(f, points: 15, for: p1)
        XCTAssertEqual(p2.totalPoints, 15, "second completion must not re-award")
        XCTAssertEqual(p2.observedFestivalIDs.count, 1)
    }

    func testObserveAndActivityShareTheSameLedger() {
        let svc = makeService()
        let f = festival("festival.y")
        let (p1, _) = svc.observeFestival(f, for: .guest())
        XCTAssertTrue(p1.observedFestivalIDs.contains("festival.y"))
        // Completing the activity afterwards awards nothing extra.
        let (p2, _) = svc.completeFestivalActivity(f, points: 25, for: p1)
        XCTAssertEqual(p2.totalPoints, p1.totalPoints)
    }

    func testDistinctFestivalsEachAwardOnce() {
        let svc = makeService()
        let (p1, _) = svc.completeFestivalActivity(festival("a"), points: 15, for: .guest())
        let (p2, _) = svc.completeFestivalActivity(festival("b"), points: 15, for: p1)
        XCTAssertEqual(p2.totalPoints, 30)
        XCTAssertEqual(Set(p2.observedFestivalIDs), ["a", "b"])
    }

    func testNegativePointsClampToZero() {
        let svc = makeService()
        let (p, _) = svc.completeFestivalActivity(festival("z"), points: -10, for: .guest())
        XCTAssertEqual(p.totalPoints, 0)
    }
}
