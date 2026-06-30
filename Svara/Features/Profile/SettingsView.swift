import SwiftUI

struct SettingsView: View {
    @Environment(AppEnvironment.self) private var env

    @State private var notificationsEnabled = false
    @State private var morningHour = 8
    @State private var eveningHour = 20
    @State private var isSavingReminders = false
    @State private var showSignOutConfirm = false
    @State private var showSignIn = false

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

            Section {
                LabeledContent("Name", value: env.profile.displayName)
                if let email = env.profile.email {
                    LabeledContent("Email", value: email)
                }
                LabeledContent("Membership", value: env.isPremium ? "Svara Plus" : "Free")

                if env.profile.isGuest {
                    Button {
                        showSignIn = true
                    } label: {
                        Label("Sign in or create an account", systemImage: "person.crop.circle.badge.plus")
                    }
                    .tint(SvaraTheme.Colors.accent)
                }
            } header: {
                Text("Account")
            } footer: {
                if env.profile.isGuest {
                    Text("Optional. Your practice already works without an account — signing in just saves your name.")
                }
            }

            Section("About") {
                LabeledContent("Version", value: appVersion)
                Link("Privacy Policy", destination: SvaraLinks.privacyPolicy)
                Link("Terms of Service", destination: SvaraLinks.termsOfService)
                Link("Support", destination: SvaraLinks.support)
            }

            if !env.profile.isGuest {
                Section {
                    Button(role: .destructive) {
                        showSignOutConfirm = true
                    } label: {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .svaraScreenBackground()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSignIn) {
            NavigationStack {
                AuthView(asSheet: true)
                    .navigationTitle("Sign In")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
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
