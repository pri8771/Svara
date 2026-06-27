import Foundation
import SwiftData
import Observation

/// Drives the mandir home — the anchor of the app. Loads the presiding devata,
/// active sankalps, the next sacred date, and recent memories from the store,
/// and refreshes whenever the person returns to the home (e.g. after fulfilling
/// a sankalp or saving a memory in a pushed screen).
@MainActor
@Observable
final class MandirHomeViewModel {
    let mandir: DigitalMandir

    private(set) var presidingDevata: Devata?
    private(set) var identity: DevotionalIdentity?
    private(set) var activeSankalps: [Sankalp] = []
    private(set) var preservedSankalps: [Sankalp] = []
    private(set) var nextSacredDate: SacredDateEntry?
    private(set) var recentMemories: [Memory] = []

    private let analytics: AnalyticsService

    init(mandir: DigitalMandir, analytics: AnalyticsService = .shared) {
        self.mandir = mandir
        self.analytics = analytics
    }

    /// (Re)load everything shown on the home from the store.
    func refresh(context: ModelContext) {
        let mandirRepo = MandirRepository(context: context)
        let timeRepo = SacredTimeRepository(context: context)

        presidingDevata = mandirRepo.devata(id: mandir.primaryDevataId)
        identity = mandirRepo.identity(for: mandir.id)

        let all = mandirRepo.sankalps(for: mandir.id)
        activeSankalps = all.filter { $0.status == .active }
        preservedSankalps = all.filter { $0.status == .fulfilled || $0.status == .preserved }

        nextSacredDate = timeRepo.next()
        recentMemories = Array(mandirRepo.memories(for: mandir.id).prefix(3))
    }

    func devata(for sankalp: Sankalp, context: ModelContext) -> Devata? {
        MandirRepository(context: context).devata(id: sankalp.devataId)
    }

    /// A warm, time-of-day greeting using the person's chosen name if given.
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let part: String
        switch hour {
        case 4..<12: part = "Good morning"
        case 12..<17: part = "Good afternoon"
        case 17..<21: part = "Good evening"
        default: part = "A quiet night"
        }
        let name = identity?.displayName.trimmingCharacters(in: .whitespaces) ?? ""
        return name.isEmpty ? part : "\(part), \(name)"
    }

    func logOpened() { analytics.log(.mandirOpened) }
    func logReturned() { analytics.log(.mandirReturned) }
    func logMemoriesViewed() { analytics.log(.memoriesViewed) }
    func logSacredTimeViewed() { analytics.log(.sacredTimeViewed) }
    func logSankalpViewed() { analytics.log(.sankalpViewed) }
}
