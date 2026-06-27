import Foundation
import SwiftData
import Observation

/// Drives the altar-first mandir home. Loads the presiding devata, the held
/// sankalp, today's lamp state, and the next sacred date, and records the act
/// of lighting the lamp (a return). Refreshes whenever the person comes back to
/// the altar after a ritual surface or a pushed screen.
@MainActor
@Observable
final class MandirHomeViewModel {
    let mandir: DigitalMandir

    private(set) var presidingDevata: Devata?
    private(set) var identity: DevotionalIdentity?
    private(set) var activeSankalps: [Sankalp] = []
    private(set) var isLit: Bool = false
    private(set) var nextSacredDate: SacredDateEntry?

    private let analytics: AnalyticsService

    init(mandir: DigitalMandir, analytics: AnalyticsService = .shared) {
        self.mandir = mandir
        self.analytics = analytics
    }

    /// The single intention held before the altar (the most recent active vow).
    var heldSankalp: Sankalp? { activeSankalps.first }

    /// (Re)load everything the altar depends on.
    func refresh(context: ModelContext) {
        let mandirRepo = MandirRepository(context: context)
        let timeRepo = SacredTimeRepository(context: context)

        presidingDevata = mandirRepo.devata(id: mandir.primaryDevataId)
        identity = mandirRepo.identity(for: mandir.id)
        activeSankalps = mandirRepo.activeSankalps(for: mandir.id)
        isLit = mandirRepo.hasReturnedToday(mandirId: mandir.id)
        nextSacredDate = timeRepo.next()
    }

    func devata(id: UUID?, context: ModelContext) -> Devata? {
        MandirRepository(context: context).devata(id: id)
    }

    /// Light the lamp: record a return (presence before the altar).
    func lightLamp(context: ModelContext) {
        let repo = MandirRepository(context: context)
        repo.recordReturn(mandirId: mandir.id, sankalpId: heldSankalp?.id)
        isLit = true
        analytics.log(.altarLit)
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
    func logMode(_ mode: MandirMode) { analytics.log(.mandirModeSelected(mode: mode.rawValue)) }
}
