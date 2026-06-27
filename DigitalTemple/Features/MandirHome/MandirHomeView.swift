import SwiftUI
import SwiftData

/// The mandir — a quiet, living sacred space and the anchor of the whole app.
/// Not a feed. Shows the presiding devata, the active sankalp, the next sacred
/// date, a gentle return action, and recent memories. Every other screen is a
/// push onto this NavigationStack.
struct MandirHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: MandirHomeViewModel
    @State private var path: [MandirRoute] = []

    init(mandir: DigitalMandir) {
        _viewModel = State(initialValue: MandirHomeViewModel(mandir: mandir))
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Metrics.sectionSpacing) {
                    MandirHeader(viewModel: viewModel)
                    ReturnCard { performReturn() }
                    activeSankalpSection
                    nextSacredDateSection
                    memoriesSection
                }
                .screenPadding()
                .padding(.vertical, 20)
            }
            .scrollIndicators(.hidden)
            .sacredScreen()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        path.append(.settings)
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(Theme.Palette.inkSecondary)
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .navigationDestination(for: MandirRoute.self) { route in
                destination(for: route)
            }
            .onAppear {
                viewModel.refresh(context: modelContext)
                viewModel.logOpened()
            }
        }
        .tint(Theme.Palette.accent)
    }

    // MARK: Sections

    @ViewBuilder
    private var activeSankalpSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeader(title: "Your Sankalp", devanagari: "संकल्प")
                Spacer()
                Button("New") { path.append(.newSankalp) }
                    .font(.sacredLabel)
                    .foregroundStyle(Theme.Palette.accent)
            }

            if viewModel.activeSankalps.isEmpty {
                SacredCard {
                    QuietState(
                        glyph: "📿",
                        message: "No sankalp rests here yet.\nName an intention to hold."
                    )
                }
                .onTapGesture { path.append(.newSankalp) }
            } else {
                ForEach(viewModel.activeSankalps) { sankalp in
                    SankalpCard(
                        sankalp: sankalp,
                        devata: viewModel.devata(for: sankalp, context: modelContext),
                        onReflect: { path.append(.reflect(sankalp)) },
                        onFulfill: { path.append(.fulfillSankalp(sankalp)) }
                    )
                    .onTapGesture { viewModel.logSankalpViewed() }
                }
            }
        }
    }

    @ViewBuilder
    private var nextSacredDateSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeader(title: "Sacred Time", devanagari: "पर्व")
                Spacer()
                Button("All dates") {
                    viewModel.logSacredTimeViewed()
                    path.append(.sacredTime)
                }
                .font(.sacredLabel)
                .foregroundStyle(Theme.Palette.accent)
            }

            if let date = viewModel.nextSacredDate {
                Button {
                    viewModel.logSacredTimeViewed()
                    path.append(.sacredTime)
                } label: {
                    NextSacredDateCard(entry: date)
                }
                .buttonStyle(.plain)
            } else {
                SacredCard { QuietState(glyph: "🗓️", message: "No upcoming dates.") }
            }
        }
    }

    @ViewBuilder
    private var memoriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeader(title: "Memories", devanagari: "स्मृति")
                Spacer()
                Button("Add") { path.append(.newMemory) }
                    .font(.sacredLabel)
                    .foregroundStyle(Theme.Palette.accent)
            }

            if viewModel.recentMemories.isEmpty {
                SacredCard {
                    QuietState(
                        glyph: "🌸",
                        message: "Memories you preserve will gather here."
                    )
                }
                .onTapGesture { path.append(.newMemory) }
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.recentMemories) { memory in
                        MemoryRow(memory: memory)
                    }
                    Button("View all memories") {
                        viewModel.logMemoriesViewed()
                        path.append(.memories)
                    }
                    .buttonStyle(.sacredQuiet)
                }
            }
        }
    }

    // MARK: Return action

    private func performReturn() {
        viewModel.logReturned()
        if let active = viewModel.activeSankalps.first {
            path.append(.reflect(active))
        } else {
            path.append(.newMemory)
        }
    }

    // MARK: Destinations

    @ViewBuilder
    private func destination(for route: MandirRoute) -> some View {
        switch route {
        case let .fulfillSankalp(sankalp):
            SankalpFulfillmentView(sankalp: sankalp)
        case let .reflect(sankalp):
            ReflectionEntryView(sankalp: sankalp)
        case .newSankalp:
            NewSankalpView(mandir: viewModel.mandir)
        case .memories:
            MemoriesView(mandir: viewModel.mandir)
        case .newMemory:
            NewMemoryView(mandir: viewModel.mandir)
        case .sacredTime:
            SacredTimeView()
        case .settings:
            SettingsView(mandir: viewModel.mandir)
        case .devotionalIdentity:
            DevotionalIdentityEditView(mandir: viewModel.mandir)
        }
    }
}

// MARK: - Header

private struct MandirHeader: View {
    let viewModel: MandirHomeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.greeting)
                .font(.sacredCaption)
                .foregroundStyle(Theme.Palette.inkSecondary)

            Text(viewModel.mandir.name)
                .font(.mandirTitle)
                .foregroundStyle(Theme.Palette.ink)

            if let devata = viewModel.presidingDevata {
                HStack(spacing: 8) {
                    Text(devata.nameDevanagari)
                        .font(.devanagari)
                        .foregroundStyle(Theme.Palette.gold)
                    Text("· \(devata.name) presides")
                        .font(.sacredLabel)
                        .foregroundStyle(Theme.Palette.inkSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Return card

private struct ReturnCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text("🪔")
                    .font(.system(size: 30))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Return to your mandir")
                        .font(.sacredHeadline)
                        .foregroundStyle(Theme.Palette.ink)
                    Text("Sit a moment. Light a lamp within.")
                        .font(.sacredLabel)
                        .foregroundStyle(Theme.Palette.inkSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundStyle(Theme.Palette.gold)
            }
            .padding(Theme.Metrics.cardPadding)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Theme.Palette.surface, Theme.Palette.gold.opacity(0.18)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.Metrics.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Metrics.cornerRadius, style: .continuous)
                    .stroke(Theme.Palette.gold.opacity(0.4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct MandirHomePreview: View {
    let container: ModelContainer
    let mandir: DigitalMandir

    init() {
        container = try! ModelContainer(
            for: DigitalMandir.self, DevotionalIdentity.self, Devata.self,
            Sankalp.self, Reflection.self, Memory.self, SacredDateEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        mandir = DigitalMandir(name: "Aai's Corner")
        container.mainContext.insert(mandir)
    }

    var body: some View {
        MandirHomeView(mandir: mandir)
            .modelContainer(container)
    }
}

#Preview {
    MandirHomePreview()
}
