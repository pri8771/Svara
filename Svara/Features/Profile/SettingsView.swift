import SwiftUI

struct SettingsView: View {
    @Environment(AppEnvironment.self) private var env

    @State private var notificationsEnabled = false
    @State private var morningHour = 8
    @State private var eveningHour = 20
    @State private var isSavingReminders = false
    @State private var showSignOutConfirm = false

    private let hours = Array(0...23)

    var body: some View {
        Form {
            Section("Daily Reminders") {
                Toggle("Practice reminders", isOn: $notificationsEnabled)
                    .tint(SvaraTheme.Colors.primary)

                if notificationsEnabled {
                    Picker("Morning", selection: $morningHour) {
                        ForEach(hours, id: \.self) { Text(hourLabel($0)).tag($0) }
                    }
                    Picker("Evening", selection: $eveningHour) {
                        ForEach(hours, id: \.self) { Text(hourLabel($0)).tag($0) }
                    }
                }
            }

            Section("Account") {
                LabeledContent("Name", value: env.profile.displayName)
                if let email = env.profile.email {
                    LabeledContent("Email", value: email)
                }
                LabeledContent("Membership", value: env.isPremium ? "Svara Plus" : "Free")
            }

            Section("About") {
                LabeledContent("Version", value: appVersion)
                Link(destination: URL(string: "https://svara.app/privacy")!) {
                    Text("Privacy Policy")
                }
                Link(destination: URL(string: "https://svara.app/terms")!) {
                    Text("Terms of Service")
                }
            }

            Section {
                Button(role: .destructive) {
                    showSignOutConfirm = true
                } label: {
                    Text("Sign Out")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .svaraScreenBackground()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadPreferences)
        .onChange(of: notificationsEnabled) { _, _ in saveReminders() }
        .onChange(of: morningHour) { _, _ in saveReminders() }
        .onChange(of: eveningHour) { _, _ in saveReminders() }
        .confirmationDialog("Sign out of Svara?", isPresented: $showSignOutConfirm, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) { Task { await env.signOut() } }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func loadPreferences() {
        notificationsEnabled = env.profile.notificationsEnabled
        morningHour = env.profile.morningReminderHour
        eveningHour = env.profile.eveningReminderHour
    }

    private func saveReminders() {
        guard !isSavingReminders else { return }
        isSavingReminders = true
        Task {
            await env.updateNotificationPreferences(
                enabled: notificationsEnabled,
                morningHour: morningHour,
                eveningHour: eveningHour
            )
            // Reflect any permission denial back into the toggle.
            notificationsEnabled = env.profile.notificationsEnabled
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
