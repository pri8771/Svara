import SwiftUI
import SwiftData

/// Compose an additional sankalp from within the mandir. Mirrors the onboarding
/// first sankalp but adds an optional presiding devata and an optional due date.
struct NewSankalpView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let mandir: DigitalMandir
    private let analytics = AnalyticsService.shared

    @State private var intention: String = ""
    @State private var forWhom: String = ""
    @State private var type: IntentionType = .gratitude
    @State private var devataId: UUID?
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @FocusState private var intentionFocused: Bool

    @Query(filter: #Predicate<Devata> { $0.isChosen }, sort: \Devata.name)
    private var chosenDevatas: [Devata]

    private var canSave: Bool {
        !intention.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SankalpFormFields(
                        intention: $intention,
                        forWhom: $forWhom,
                        type: $type,
                        intentionFocused: $intentionFocused
                    )

                    if !chosenDevatas.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader(title: "Before which devata")
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    devataChip(name: "None", devanagari: nil, selected: devataId == nil) {
                                        devataId = nil
                                    }
                                    ForEach(chosenDevatas) { d in
                                        devataChip(name: d.name, devanagari: d.nameDevanagari, selected: devataId == d.id) {
                                            devataId = d.id
                                        }
                                    }
                                }
                                .padding(.horizontal, 2)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: $hasDueDate) {
                            Text("Hold until a date")
                                .font(.sacredLabel)
                                .foregroundStyle(Theme.Palette.ink)
                        }
                        .tint(Theme.Palette.accent)
                        if hasDueDate {
                            DatePicker("By", selection: $dueDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .tint(Theme.Palette.accent)
                        }
                    }
                }
                .screenPadding()
                .padding(.vertical, 16)
            }

            Button("Make this sankalp", action: save)
                .buttonStyle(.sacred)
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.5)
                .screenPadding()
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
        }
        .sacredScreen()
        .navigationTitle("New Sankalp")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if devataId == nil { devataId = mandir.primaryDevataId } }
    }

    private func devataChip(name: String, devanagari: String?, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let devanagari { Text(devanagari) }
                Text(name).font(.sacredLabel)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .foregroundStyle(selected ? Theme.Palette.background : Theme.Palette.ink)
            .background(selected ? Theme.Palette.accent : Theme.Palette.surface)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(selected ? .clear : Theme.Palette.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func save() {
        let repo = MandirRepository(context: modelContext)
        let who = forWhom.trimmingCharacters(in: .whitespaces)
        repo.createSankalp(
            intention: intention.trimmingCharacters(in: .whitespaces),
            forWhom: who.isEmpty ? nil : who,
            type: type,
            devataId: devataId,
            dueDate: hasDueDate ? dueDate : nil,
            mandirId: mandir.id
        )
        analytics.log(.sankalpCreated(type: type.rawValue))
        dismiss()
    }
}
