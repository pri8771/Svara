import SwiftUI
import SwiftData

/// A small, quiet settings screen. v0 holds only what belongs to the sacred
/// space: the devotional identity, a note that everything stays on the device,
/// and (in debug builds) a view of the feature flags awaiting later versions.
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    let mandir: DigitalMandir

    @State private var presidingDevataName: String?
    @State private var displayName: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Metrics.sectionSpacing) {
                // Devotional identity
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Your devotional identity")
                    NavigationLink(value: MandirRoute.devotionalIdentity) {
                        SacredCard {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mandir.name)
                                        .font(.sacredHeadline)
                                        .foregroundStyle(Theme.Palette.ink)
                                    Text(subtitle)
                                        .font(.sacredCaption)
                                        .foregroundStyle(Theme.Palette.inkSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                                    .foregroundStyle(Theme.Palette.brass)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                // Privacy
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Your space is private")
                    SacredCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Everything stays on this device", systemImage: "lock")
                                .font(.sacredCaption)
                                .foregroundStyle(Theme.Palette.ink)
                            Text("My Mandir makes no network calls and shares nothing. Your mandir is yours alone.")
                                .font(.sacredLabel)
                                .foregroundStyle(Theme.Palette.inkSecondary)
                        }
                    }
                }

                // About
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "About")
                    SacredCard {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(AppConstants.appName)
                                .font(.sacredHeadline)
                                .foregroundStyle(Theme.Palette.ink)
                            Text("A sacred relationship system for Hindu life.")
                                .font(.sacredLabel)
                                .foregroundStyle(Theme.Palette.inkSecondary)
                            Text("Version \(appVersion)")
                                .font(.sacredLabel)
                                .foregroundStyle(Theme.Palette.brass)
                        }
                    }
                }

                #if DEBUG
                FeatureFlagInspector()
                #endif
            }
            .screenPadding()
            .padding(.vertical, 16)
        }
        .sacredScreen()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: load)
    }

    private var subtitle: String {
        var parts: [String] = []
        if !displayName.isEmpty { parts.append(displayName) }
        if let name = presidingDevataName { parts.append("\(name) presides") }
        return parts.isEmpty ? "Tap to edit" : parts.joined(separator: " · ")
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return v
    }

    private func load() {
        let repo = MandirRepository(context: modelContext)
        presidingDevataName = repo.devata(id: mandir.primaryDevataId)?.name
        displayName = repo.identity(for: mandir.id)?.displayName ?? ""
    }
}

#if DEBUG
/// A developer-only readout of which features are live in this build. Confirms
/// the v1/v2 surface is wired but off.
private struct FeatureFlagInspector: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Feature flags (debug)")
            SacredCard {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(FeatureFlag.allCases, id: \.rawValue) { flag in
                        HStack {
                            Text(flag.title)
                                .font(.sacredLabel)
                                .foregroundStyle(Theme.Palette.ink)
                            Spacer()
                            Text(flag.isEnabled ? "on" : "off")
                                .font(.sacredLabel)
                                .foregroundStyle(flag.isEnabled ? Theme.Palette.calm : Theme.Palette.inkSecondary)
                        }
                    }
                }
            }
        }
    }
}
#endif
