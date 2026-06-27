import SwiftUI
import SwiftData

/// The mandir — an altar-first sacred space and the anchor of the whole app.
/// A persistent altar (header, lamp, mode selector) sits at the top; beneath it
/// the selected mode swaps between simply being present (Altar), placing an
/// Offering, leaving a Reflection, or reading the Thread of returns. Not a feed,
/// not a dashboard, no tab bar — deeper screens are pushes onto this stack.
struct MandirHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: MandirHomeViewModel
    @State private var path: [MandirRoute] = []
    @State private var mode: MandirMode = .altar

    init(mandir: DigitalMandir) {
        _viewModel = State(initialValue: MandirHomeViewModel(mandir: mandir))
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: Theme.Metrics.sectionSpacing) {
                    AltarHeader(
                        greeting: viewModel.greeting,
                        mandirName: viewModel.mandir.name,
                        devataName: viewModel.presidingDevata?.name,
                        onSettings: { path.append(.settings) }
                    )

                    AltarStateView(
                        isLit: viewModel.isLit,
                        devataDevanagari: viewModel.presidingDevata?.nameDevanagari,
                        onLight: lightLamp
                    )

                    MandirModeSelector(selection: $mode) { viewModel.logMode($0) }

                    surface
                        .transition(.opacity)
                }
                .screenPadding()
                .padding(.vertical, 20)
            }
            .scrollIndicators(.hidden)
            .sacredScreen()
            .toolbar(.hidden, for: .navigationBar)
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

    // MARK: Mode surfaces

    @ViewBuilder
    private var surface: some View {
        switch mode {
        case .altar:
            AltarSurface(
                heldSankalp: viewModel.heldSankalp,
                nextSacredDate: viewModel.nextSacredDate,
                onMakeSankalp: { path.append(.newSankalp) },
                onReflect: { withAnimation { mode = .reflect } },
                onOpenSacredTime: { path.append(.sacredTime) }
            )
        case .offer:
            OfferView(
                mandir: viewModel.mandir,
                heldSankalp: viewModel.heldSankalp,
                onCommitted: returnToAltar
            )
        case .reflect:
            ReflectView(
                mandir: viewModel.mandir,
                heldSankalp: viewModel.heldSankalp,
                onCommitted: returnToAltar,
                onFulfill: { path.append(.fulfillSankalp($0)) },
                onMakeSankalp: { path.append(.newSankalp) }
            )
        case .thread:
            ThreadView(
                mandir: viewModel.mandir,
                onChanged: { viewModel.refresh(context: modelContext) }
            )
        }
    }

    // MARK: Actions

    private func lightLamp() {
        viewModel.lightLamp(context: modelContext)
    }

    /// After an offering or reflection, refresh and settle back at the altar.
    private func returnToAltar() {
        viewModel.refresh(context: modelContext)
        withAnimation(.easeInOut) { mode = .altar }
    }

    // MARK: Destinations

    @ViewBuilder
    private func destination(for route: MandirRoute) -> some View {
        switch route {
        case let .fulfillSankalp(sankalp):
            SankalpFulfillmentView(sankalp: sankalp)
        case .newSankalp:
            NewSankalpView(mandir: viewModel.mandir)
        case .sacredTime:
            SacredTimeView()
        case .settings:
            SettingsView(mandir: viewModel.mandir)
        case .devotionalIdentity:
            DevotionalIdentityEditView(mandir: viewModel.mandir)
        }
    }
}

private struct MandirHomePreview: View {
    let container: ModelContainer
    let mandir: DigitalMandir

    init() {
        container = try! ModelContainer(
            for: DigitalMandir.self, DevotionalIdentity.self, Devata.self,
            Sankalp.self, Reflection.self, Memory.self, SacredDateEntry.self,
            MandirReturn.self,
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
