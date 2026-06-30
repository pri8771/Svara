import SwiftUI
import UIKit

/// Sign-in / registration screen. Backed by `AuthService`, so swapping in
/// Firebase Auth later requires no changes here.
struct AuthView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss

    /// When presented as an optional sheet (e.g. from Settings), the screen
    /// dismisses itself on success and offers "Not now" instead of the
    /// first-run "Continue as Guest".
    var asSheet: Bool = false

    @State private var mode: Mode = .signIn
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isWorking = false

    enum Mode { case signIn, register }

    var body: some View {
        ScrollView {
            VStack(spacing: SvaraTheme.Spacing.xl) {
                header
                form
                actions
            }
            .padding(.horizontal, SvaraTheme.Spacing.screenMargin)
            .padding(.vertical, SvaraTheme.Spacing.xxl)
        }
        .svaraScreenBackground()
    }

    private var header: some View {
        VStack(spacing: SvaraTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(SvaraTheme.Gradients.dawn)
                    .frame(width: 96, height: 96)
                Image("SvaraMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .accessibilityHidden(true)
            }
            Text("Svara")
                .font(.svaraDisplay)
                .foregroundStyle(SvaraTheme.Colors.textPrimary)
            Text(mode == .signIn ? "Welcome back" : "Begin your practice")
                .font(.svaraBody)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
        }
        .padding(.top, SvaraTheme.Spacing.xl)
    }

    private var form: some View {
        SvaraCard {
            VStack(spacing: SvaraTheme.Spacing.md) {
                if mode == .register {
                    field(icon: "person.fill", placeholder: "Your name", text: $name)
                }
                field(icon: "envelope.fill", placeholder: "Email", text: $email, keyboard: .emailAddress)
                field(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.svaraCaption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var actions: some View {
        VStack(spacing: SvaraTheme.Spacing.md) {
            PrimaryButton(
                title: mode == .signIn ? "Sign In" : "Create Account",
                isLoading: isWorking
            ) { Task { await submit() } }

            Button {
                withAnimation { mode = mode == .signIn ? .register : .signIn; errorMessage = nil }
            } label: {
                Text(mode == .signIn ? "New here? Create an account" : "Already have an account? Sign in")
                    .font(.svaraCallout)
                    .foregroundStyle(SvaraTheme.Colors.accent)
            }

            Divider().padding(.vertical, SvaraTheme.Spacing.sm)

            if asSheet {
                SecondaryButton(title: "Not now", systemImage: "xmark") {
                    dismiss()
                }
            } else {
                SecondaryButton(title: "Continue as Guest", systemImage: "sparkles") {
                    Task { await env.continueAsGuest() }
                }
            }
        }
    }

    private func field(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        isSecure: Bool = false
    ) -> some View {
        HStack(spacing: SvaraTheme.Spacing.md) {
            Image(systemName: icon)
                .foregroundStyle(SvaraTheme.Colors.textSecondary)
                .frame(width: 22)
            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                        .keyboardType(keyboard)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .font(.svaraBody)
        }
        .padding(.vertical, SvaraTheme.Spacing.md)
        .padding(.horizontal, SvaraTheme.Spacing.md)
        .background(SvaraTheme.Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: SvaraTheme.Radius.sm, style: .continuous))
    }

    private func submit() async {
        errorMessage = nil
        isWorking = true
        defer { isWorking = false }
        do {
            switch mode {
            case .signIn:
                try await env.signIn(email: email, password: password)
            case .register:
                try await env.register(displayName: name, email: email, password: password)
            }
            if asSheet { dismiss() }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}

#Preview {
    AuthView().environment(AppEnvironment.preview())
}
