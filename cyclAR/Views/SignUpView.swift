//
//  SignUpView.swift
//  cyclAR
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var coverage: SafetyAlertCoverage = .medAndHigh
    @State private var alertMethods: Set<AlertMethod> = [.display]
    @State private var errorMsg: String?
    @State private var didSucceed = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.surfaceGray.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // ── ACCOUNT INFO ─────────────────────────────
                        FormSection(title: "Account Info") {
                            FormField(label: "Full Name", placeholder: "Jane Doe", text: $name)
                            Divider().padding(.horizontal, 14)
                            FormField(label: "Email", placeholder: "you@example.com", text: $email,
                                      keyboardType: .emailAddress, autoCapitalize: false)
                            Divider().padding(.horizontal, 14)
                            FormSecureField(label: "Password", placeholder: "Min. 6 characters", text: $password)
                            Divider().padding(.horizontal, 14)
                            FormSecureField(label: "Confirm Password", placeholder: "Repeat password", text: $confirmPassword)
                        }

                        // ── SAFETY ALERT COVERAGE ─────────────────────
                        FormSection(title: "Alert Coverage") {
                            ForEach(SafetyAlertCoverage.allCases, id: \.self) { option in
                                Button {
                                    coverage = option
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "shield.lefthalf.filled")
                                            .font(.system(size: 14))
                                            .foregroundColor(.brand)
                                            .frame(width: 20)
                                        Text(option.rawValue)
                                            .font(.cyclARBody)
                                            .foregroundColor(.appBlack)
                                        Spacer()
                                        SelectionIndicator(isSelected: coverage == option)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                }
                                if option != SafetyAlertCoverage.allCases.last {
                                    Divider().padding(.horizontal, 14)
                                }
                            }
                        }

                        // ── ALERT METHODS ─────────────────────────────
                        FormSection(title: "Alert Methods") {
                            ForEach(AlertMethod.allCases, id: \.self) { method in
                                Button {
                                    if alertMethods.contains(method) { alertMethods.remove(method) }
                                    else { alertMethods.insert(method) }
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: methodIcon(method))
                                            .font(.system(size: 14))
                                            .foregroundColor(.brand)
                                            .frame(width: 20)
                                        Text(method.rawValue)
                                            .font(.cyclARBody)
                                            .foregroundColor(.appBlack)
                                        Spacer()
                                        SelectionIndicator(isSelected: alertMethods.contains(method))
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                }
                                if method != AlertMethod.allCases.last {
                                    Divider().padding(.horizontal, 14)
                                }
                            }
                        }

                        // ── ERROR / SUCCESS ───────────────────────────
                        if let err = errorMsg {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 12))
                                Text(err)
                                    .font(.cyclARCaption)
                            }
                            .foregroundColor(.brand)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                        }

                        if didSucceed {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                Text("Account created! You can now log in.")
                                    .font(.cyclARCaption)
                            }
                            .foregroundColor(Color(hex: "#3B6D11"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                        }

                        // ── CREATE BUTTON ─────────────────────────────
                        Button {
                            handleSignUp()
                        } label: {
                            Text("Create Account")
                                .font(.cyclARHeadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.brand)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(.cyclARBody)
                        .foregroundColor(.brand)
                }
            }
        }
    }

    private func handleSignUp() {
        errorMsg = nil
        didSucceed = false
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMsg = "Please fill in all fields."
            return
        }
        guard password == confirmPassword else {
            errorMsg = "Passwords do not match."
            return
        }
        guard password.count >= 6 else {
            errorMsg = "Password must be at least 6 characters."
            return
        }
        guard !alertMethods.isEmpty else {
            errorMsg = "Select at least one alert method."
            return
        }
        let profile = UserProfile(
            name: name, email: email, password: password,
            safetyAlertCoverage: coverage,
            alertMethods: Array(alertMethods)
        )
        userStore.register(profile)
        didSucceed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
    }

    private func methodIcon(_ method: AlertMethod) -> String {
        switch method {
        case .display: return "display"
        case .haptics: return "iphone.radiowaves.left.and.right"
        }
    }
}

// MARK: - Reusable form sub-views

struct FormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeaderLabel(text: title)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.borderGray, lineWidth: 1)
            )
            .padding(.horizontal, 24)
        }
    }
}

struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autoCapitalize: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            SectionHeaderLabel(text: label)
            TextField(placeholder, text: $text)
                .font(.cyclARBody)
                .foregroundColor(.appBlack)
                .keyboardType(keyboardType)
                .autocapitalization(autoCapitalize ? .words : .none)
                .disableAutocorrection(!autoCapitalize)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
    }
}

struct FormSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            SectionHeaderLabel(text: label)
            SecureField(placeholder, text: $text)
                .font(.cyclARBody)
                .foregroundColor(.appBlack)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
    }
}

struct SelectionIndicator: View {
    let isSelected: Bool
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.brand : Color.clear)
                .frame(width: 18, height: 18)
            Circle()
                .stroke(isSelected ? Color.brand : Color.borderGray, lineWidth: 1.5)
                .frame(width: 18, height: 18)
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}
