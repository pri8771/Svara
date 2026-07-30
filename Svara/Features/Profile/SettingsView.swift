import SwiftUI

struct SettingsView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.openURL) private var openURL

    @State private var notificationsEnabled = false
    @State private var morningHour = 8
    @State private var eveningHour = 20
    @State private var isSavingReminders = false
    @State private var reminderSaveQueued = false
    @State private var showNotificationSettings = false
    @State private var showProfileEditor = false

    private let hours = Array(0...23)

    var body: some View {
        Form {
            Section {
                Toggle("Practice reminders", isOn: $notificationsEnabled)
                    .tint(SvaraTheme.Colors.primary)
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)

                if notificationsEnabled {
                    Picker("Morning", selection: $morningHour) {
                        ForEach(hours, id: \.self) { Text(hourLabel($0)).tag($0) }
                    }
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)
                    .tint(SvaraTheme.Colors.accent)
                    Picker("Evening", selection: $eveningHour) {
                        ForEach(hours, id: \.self) { Text(hourLabel($0)).tag($0) }
                    }
                    .foregroundStyle(SvaraTheme.Colors.textPrimary)
                    .tint(SvaraTheme.Colors.accent)
                }
            } header: {
                settingsHeader("Daily Reminders")
            }
            .listRowBackground(SvaraTheme.Colors.surface)

            Section {
                LabeledContent {
                    Text(env.profile.displayName)
                        .foregroundStyle(SvaraTheme.Colors.textSecondary)
                } label: {
                    Text("Name")
                        .foregroundStyle(SvaraTheme.Colors.textPrimary)
                }

                Button {
                    showProfileEditor = true
                } label: {
                    Label("Edit display name", systemImage: "pencil")
                }
                .tint(SvaraTheme.Colors.accent)
            } header: {
                settingsHeader("Local Profile")
            } footer: {
                Text("No account is created. Your name and progress stay on this iPhone.")
                    .foregroundStyle(SvaraTheme.Colors.textSecondary)
            }
            .listRowBackground(SvaraTheme.Colors.surface)

            Section {
                LabeledContent {
                    Text(appVersion)
                        .foregroundStyle(SvaraTheme.Colors.textSecondary)
                } label: {
                    Text("Version")
                        .foregroundStyle(SvaraTheme.Colors.textPrimary)
                }
                Link("Privacy Policy", destination: SvaraLinks.privacyPolicy)
                Link("Terms of Service", destination: SvaraLinks.termsOfService)
                Link("Support", destination: SvaraLinks.support)
            } header: {
                settingsHeader("About")
            }
            .foregroundStyle(SvaraTheme.Colors.accent)
            .listRowBackground(SvaraTheme.Colors.surface)
        }
        .scrollContentBackground(.hidden)
        .svaraScreenBackground()
        .tint(SvaraTheme.Colors.accent)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showProfileEditor) {
            NavigationStack {
                LocalProfileEditorView()
                    .navigationTitle("Edit Profile")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear(perform: loadPreferences)
        .onChange(of: notificationsEnabled) { _, _ in saveReminders() }
        .onChange(of: morningHour) { _, _ in saveReminders() }
        .onChange(of: eveningHour) { _, _ in saveReminders() }
        .alert("Reminders are turned off", isPresented: $showNotificationSettings) {
            Button("Not now", role: .cancel) {}
            Button("Open Settings") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                openURL(url)
            }
        } message: {
            Text("Allow notifications in iPhone Settings if you want Svara practice reminders.")
        }
    }

    private func loadPreferences() {
        notificationsEnabled = env.profile.notificationsEnabled
        morningHour = env.profile.morningReminderHour
        eveningHour = env.profile.eveningReminderHour
    }

    private func saveReminders() {
        guard !isSavingReminders else {
            reminderSaveQueued = true
            return
        }
        isSavingReminders = true
        Task {
            repeat {
                reminderSaveQueued = false
                let requestedEnabled = notificationsEnabled
                let requestedMorning = morningHour
                let requestedEvening = eveningHour
                let accepted = await env.updateNotificationPreferences(
                    enabled: requestedEnabled,
                    morningHour: requestedMorning,
                    eveningHour: requestedEvening
                )
                if requestedEnabled && !accepted {
                    notificationsEnabled = false
                    showNotificationSettings = true
                }
            } while reminderSaveQueued
            isSavingReminders = false
        }
    }

    private func hourLabel(_ hour: Int) -> String {
        var components = DateComponents()
        components.hour = hour
        let date = Calendar.current.date(from: components) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter.string(from: date)
    }

    private func settingsHeader(_ title: String) -> some View {
        Text(title)
            .font(.svaraCaption.weight(.bold))
            .foregroundStyle(SvaraTheme.Colors.textPrimary)
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return version
    }
}

#Preview {
    NavigationStack {
        SettingsView().environment(AppEnvironment.preview())
    }
}
