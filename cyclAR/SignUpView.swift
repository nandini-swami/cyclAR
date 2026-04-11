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
            Form {
                Section(header: Text("Account Info")) {
                    TextField("Full Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                    // FIX: added confirm password so user doesn't mistype
                    SecureField("Confirm Password", text: $confirmPassword)
                }

                Section(header: Text("Road Safety Alert Detection Coverage")) {
                    ForEach(SafetyAlertCoverage.allCases, id: \.self) { option in
                        HStack {
                            Text(option.rawValue)
                            Spacer()
                            if coverage == option {
                                Image(systemName: "checkmark").foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { coverage = option }
                    }
                }

                Section(header: Text("How to Receive Road Safety Alerts")) {
                    ForEach(AlertMethod.allCases, id: \.self) { method in
                        HStack {
                            Image(systemName: icon(for: method))
                                .foregroundColor(.green)
                                .frame(width: 24)
                            Text(method.rawValue)
                            Spacer()
                            if alertMethods.contains(method) {
                                Image(systemName: "checkmark").foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if alertMethods.contains(method) {
                                alertMethods.remove(method)
                            } else {
                                alertMethods.insert(method)
                            }
                        }
                    }
                }

                if let err = errorMsg {
                    Section {
                        Text(err).foregroundColor(.red).font(.caption)
                    }
                }

                if didSucceed {
                    Section {
                        Text("Account created! You can now log in.")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }

                Section {
                    Button("Create Account") {
                        handleSignUp()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
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
            name: name,
            email: email,
            password: password,           // password is now stored in the model
            safetyAlertCoverage: coverage,
            alertMethods: Array(alertMethods)
        )

        // FIX: call register() (not save() which doesn't exist)
        // register() saves to disk WITHOUT logging in — user must log in manually
        userStore.register(profile)
        didSucceed = true

        // Brief delay so the user sees the success message, then dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }

    private func icon(for method: AlertMethod) -> String {
        switch method {
        case .display: return "display"
        case .haptics: return "iphone.radiowaves.left.and.right"
        }
    }
}
