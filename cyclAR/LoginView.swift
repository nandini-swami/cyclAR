//
//  LoginView.swift
//  cyclAR
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var errorMsg: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "bicycle.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.green)
                    Text("CyclAR")
                        .font(.system(size: 36, weight: .bold))
                    Text("Smart Helmet Navigation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)
                .padding(.bottom, 40)

                // Fields
                VStack(spacing: 14) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)

                    if let err = errorMsg {
                        Text(err)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }

                    Button("Log In") {
                        handleLogin()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .frame(maxWidth: .infinity)
                    .controlSize(.large)
                }
                .padding(.horizontal, 28)

                Spacer()

                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    Button("Sign Up") { showSignUp = true }
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .padding(.bottom, 36)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSignUp) {
                SignUpView()
                    .environmentObject(userStore)
            }
        }
    }

    private func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMsg = "Please enter your email and password."
            return
        }

        // FIX: use register() which calls login() — checks BOTH email AND password
        let success = userStore.login(email: email, password: password)

        if success {
            errorMsg = nil
        } else if userStore.currentUser == nil {
            errorMsg = "No account found. Please sign up first."
        } else {
            errorMsg = "Incorrect email or password."
        }
    }
}
