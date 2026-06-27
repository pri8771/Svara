import Foundation
import SwiftData

/// Central data access for the mandir and everything that lives within it:
/// the devotional identity, devatas, sankalps, reflections, and memories.
///
/// View models hold a repository rather than touching `ModelContext` directly,
/// keeping persistence behind one seam (so iCloud sync, etc. can arrive later
/// without rewriting feature code). Live lists in views may still use `@Query`.
@MainActor
struct MandirRepository {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: Mandir

    func currentMandir() -> DigitalMandir? {
        try? context.fetch(FetchDescriptor<DigitalMandir>()).first
    }

    @discardableResult
    func createMandir(name: String, primaryDevataId: UUID?) -> DigitalMandir {
        let mandir = DigitalMandir(name: name, primaryDevataId: primaryDevataId)
        context.insert(mandir)
        save()
        return mandir
    }

    func renameMandir(_ mandir: DigitalMandir, to name: String) {
        mandir.name = name
        save()
    }

    func setPrimaryDevata(_ mandir: DigitalMandir, devataId: UUID?) {
        mandir.primaryDevataId = devataId
        save()
    }

    // MARK: Devotional identity

    func identity(for mandirId: UUID) -> DevotionalIdentity? {
        let predicate = #Predicate<DevotionalIdentity> { $0.mandirId == mandirId }
        return try? context.fetch(FetchDescriptor(predicate: predicate)).first
    }

    @discardableResult
    func createIdentity(
        displayName: String,
        onboardingIntention: String,
        traditionLeaning: String?,
        mandirId: UUID
    ) -> DevotionalIdentity {
        let identity = DevotionalIdentity(
            displayName: displayName,
            onboardingIntention: onboardingIntention,
            traditionLeaning: traditionLeaning,
            mandirId: mandirId
        )
        context.insert(identity)
        save()
        return identity
    }

    // MARK: Devatas

    func allDevatas() -> [Devata] {
        let descriptor = FetchDescriptor<Devata>(sortBy: [SortDescriptor(\.name)])
        return (try? context.fetch(descriptor)) ?? []
    }

    func devata(id: UUID?) -> Devata? {
        guard let id else { return nil }
        let predicate = #Predicate<Devata> { $0.id == id }
        return try? context.fetch(FetchDescriptor(predicate: predicate)).first
    }

    func chosenDevatas() -> [Devata] {
        allDevatas().filter { $0.isChosen }
    }

    func setChosen(_ devata: Devata, _ chosen: Bool) {
        devata.isChosen = chosen
        save()
    }

    // MARK: Sankalps

    func sankalps(for mandirId: UUID) -> [Sankalp] {
        let predicate = #Predicate<Sankalp> { $0.mandirId == mandirId }
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\Sankalp.startDate, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func activeSankalps(for mandirId: UUID) -> [Sankalp] {
        sankalps(for: mandirId).filter { $0.status == .active }
    }

    @discardableResult
    func createSankalp(
        intention: String,
        forWhom: String?,
        type: IntentionType,
        devataId: UUID?,
        dueDate: Date?,
        mandirId: UUID
    ) -> Sankalp {
        let sankalp = Sankalp(
            intention: intention,
            forWhom: forWhom,
            intentionType: type,
            devataId: devataId,
            dueDate: dueDate,
            mandirId: mandirId
        )
        context.insert(sankalp)
        save()
        return sankalp
    }

    func fulfill(_ sankalp: Sankalp) {
        sankalp.status = .fulfilled
        save()
    }

    func updateStatus(_ sankalp: Sankalp, to status: SankalpStatus) {
        sankalp.status = status
        save()
    }

    // MARK: Reflections

    func reflections(for sankalpId: UUID) -> [Reflection] {
        let predicate = #Predicate<Reflection> { $0.sankalpId == sankalpId }
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\Reflection.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    @discardableResult
    func addReflection(content: String, mood: Mood, sankalpId: UUID) -> Reflection {
        let reflection = Reflection(sankalpId: sankalpId, content: content, mood: mood)
        context.insert(reflection)
        save()
        return reflection
    }

    // MARK: Memories

    func memories(for mandirId: UUID) -> [Memory] {
        let predicate = #Predicate<Memory> { $0.mandirId == mandirId }
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\Memory.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    @discardableResult
    func saveMemory(title: String, content: String, type: MemoryType, mandirId: UUID) -> Memory {
        let memory = Memory(title: title, content: content, type: type, mandirId: mandirId)
        context.insert(memory)
        save()
        return memory
    }

    // MARK: Returns (the Thread)

    func returns(for mandirId: UUID) -> [MandirReturn] {
        let predicate = #Predicate<MandirReturn> { $0.mandirId == mandirId }
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\MandirReturn.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// Whether the lamp has already been lit (any return recorded) today.
    func hasReturnedToday(mandirId: UUID) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = #Predicate<MandirReturn> {
            $0.mandirId == mandirId && $0.date >= startOfDay
        }
        let count = (try? context.fetchCount(FetchDescriptor(predicate: predicate))) ?? 0
        return count > 0
    }

    @discardableResult
    func recordReturn(
        mandirId: UUID,
        sankalpId: UUID? = nil,
        offeringKind: OfferingKind? = nil,
        reflectionId: UUID? = nil,
        note: String? = nil
    ) -> MandirReturn {
        let entry = MandirReturn(
            mandirId: mandirId,
            sankalpId: sankalpId,
            offeringKind: offeringKind,
            reflectionId: reflectionId,
            note: note
        )
        context.insert(entry)
        save()
        return entry
    }

    // MARK: Persistence

    func save() {
        do {
            try context.save()
        } catch {
            // v0 is fully local; a failed save is logged, never surfaced loudly.
            print("⚠️ MandirRepository save failed: \(error)")
        }
    }
}
