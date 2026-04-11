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
            ZStack {
                Color.surfaceGray.ignoresSafeArea()
 
                VStack(spacing: 0) {
 
                    Spacer()
 
                    // ── HERO ─────────────────────────────────────────
                    VStack(spacing: 10) {
                        // Helmet icon
                        ZStack {
                            Circle()
                                .fill(Color.brand)
                                .frame(width: 64, height: 64)
                            Image(systemName: "bicycle.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
 
                        HStack(spacing: 0) {
                            Text("Cycl")
                                .font(.cyclARLargeTitle)
                                .foregroundColor(.appBlack)
                            Text("AR")
                                .font(.cyclARLargeTitle)
                                .foregroundColor(.brand)
                        }
 
                        Text("Smart Helmet Navigation")
                            .font(.cyclARBody)
                            .foregroundColor(.textMuted)
                    }
                    .padding(.bottom, 40)
 
                    // ── FORM CARD ─────────────────────────────────────
                    VStack(spacing: 0) {
                        VStack(spacing: 16) {
 
                            // Email field
                            VStack(alignment: .leading, spacing: 6) {
                                SectionHeaderLabel(text: "Email")
                                TextField("", text: $email)
                                    .font(.cyclARBody)
                                    .foregroundColor(.appBlack)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(Color.surfaceGray)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.borderGray, lineWidth: 1.5)
                                    )
                            }
 
                            // Password field
                            VStack(alignment: .leading, spacing: 6) {
                                SectionHeaderLabel(text: "Password")
                                SecureField("", text: $password)
                                    .font(.cyclARBody)
                                    .foregroundColor(.appBlack)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(Color.surfaceGray)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.borderGray, lineWidth: 1.5)
                                    )
                            }
 
                            // Error
                            if let err = errorMsg {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 12))
                                    Text(err)
                                        .font(.cyclARCaption)
                                }
                                .foregroundColor(.brand)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
 
                            // Log In button
                            Button {
                                handleLogin()
                            } label: {
                                Text("Log In")
                                    .font(.cyclARHeadline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.brand)
                                    .cornerRadius(12)
                            }
                            .padding(.top, 4)
                        }
                        .padding(20)
                    }
                    .background(Color.white)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.borderGray, lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
 
                    Spacer()
 
                    // ── SIGN UP LINK ──────────────────────────────────
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.cyclARCaption)
                            .foregroundColor(.textMuted)
                        Button("Sign Up") {
                            showSignUp = true
                        }
                        .font(.cyclARCaption)
                        .fontWeight(.semibold)
                        .foregroundColor(.brand)
                    }
                    .padding(.bottom, 36)
                }
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
