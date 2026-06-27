import SwiftUI
import SwiftData

/// Edit the devotional identity and the mandir's name and presiding devata.
/// Changes are saved on confirm and reflected on the home when it reappears.
struct DevotionalIdentityEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let mandir: DigitalMandir
    private let analytics = AnalyticsService.shared

    @State private var mandirName: String = ""
    @State private var displayName: String = ""
    @State private var traditionLeaning: String = ""
    @State private var primaryDevataId: UUID?
    @State private var loaded = false

    @Query(filter: #Predicate<Devata> { $0.isChosen }, sort: \Devata.name)
    private var chosenDevatas: [Devata]

    private var canSave: Bool {
        !mandirName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Mandir name")
                        TextField("My Mandir", text: $mandirName)
                            .textInputAutocapitalization(.words)
                            .sacredField()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "How you wish to be known")
                        TextField("Optional", text: $displayName)
                            .textInputAutocapitalization(.words)
                            .sacredField()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Tradition you feel closest to")
                        TextField("Optional — e.g. Shaiva, Vaishnava, Shakta", text: $traditionLeaning)
                            .sacredField()
                    }

                    if !chosenDevatas.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader(title: "Who presides over your mandir")
                            ForEach(chosenDevatas) { d in
                                Button {
                                    primaryDevataId = d.id
                                } label: {
                                    HStack {
                                        Text(d.nameDevanagari)
                                            .font(.devanagari)
                                            .foregroundStyle(Theme.Palette.gold)
                                        Text(d.name)
                                            .font(.sacredHeadline)
                                            .foregroundStyle(Theme.Palette.ink)
                                        Spacer()
                                        Image(systemName: primaryDevataId == d.id ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(primaryDevataId == d.id ? Theme.Palette.accent : Theme.Palette.hairline)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(Theme.Palette.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(primaryDevataId == d.id ? Theme.Palette.accent : Theme.Palette.hairline,
                                                    lineWidth: primaryDevataId == d.id ? 2 : 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .screenPadding()
                .padding(.vertical, 16)
            }

            Button("Save", action: save)
                .buttonStyle(.sacred)
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.5)
                .screenPadding()
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
        }
        .sacredScreen()
        .navigationTitle("Devotional Identity")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadIfNeeded)
    }

    private func loadIfNeeded() {
        guard !loaded else { return }
        let repo = MandirRepository(context: modelContext)
        mandirName = mandir.name
        primaryDevataId = mandir.primaryDevataId
        if let identity = repo.identity(for: mandir.id) {
            displayName = identity.displayName
            traditionLeaning = identity.traditionLeaning ?? ""
        }
        loaded = true
    }

    private func save() {
        let repo = MandirRepository(context: modelContext)
        repo.renameMandir(mandir, to: mandirName.trimmingCharacters(in: .whitespaces))
        repo.setPrimaryDevata(mandir, devataId: primaryDevataId)

        if let identity = repo.identity(for: mandir.id) {
            identity.displayName = displayName.trimmingCharacters(in: .whitespaces)
            let tradition = traditionLeaning.trimmingCharacters(in: .whitespaces)
            identity.traditionLeaning = tradition.isEmpty ? nil : tradition
            repo.save()
        }

        analytics.log(.devotionalIdentityEdited)
        dismiss()
    }
}
