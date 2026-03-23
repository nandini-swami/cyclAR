//
//  ProfileView.swift
//  cyclAR
//
//  Created by Shruti Agarwal on 3/23/26.
//


// ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var showingLogoutConfirm = false

    var body: some View {
        NavigationView {
            Group {
                if let user = userStore.currentUser {
                    Form {
                        // Account
                        Section(header: Text("Account")) {
                            LabeledContent("Name", value: user.name)
                            LabeledContent("Email", value: user.email)
                        }

                        // Safety Coverage
                        Section(header: Text("Road Safety Alert Coverage")) {
                            HStack {
                                Image(systemName: "shield.lefthalf.filled")
                                    .foregroundColor(.orange)
                                Text(user.safetyAlertCoverage.rawValue)
                                    .font(.subheadline)
                            }
                        }

                        // Alert Methods
                        Section(header: Text("Alert Methods")) {
                            ForEach(user.alertMethods, id: \.self) { method in
                                HStack {
                                    Image(systemName: icon(for: method))
                                        .foregroundColor(.green)
                                        .frame(width: 24)
                                    Text(method.rawValue)
                                }
                            }
                        }

                        // Helmet
                        Section(header: Text("Helmet")) {
                            LabeledContent("Connection", value: "cyclAR Helmet")
                            LabeledContent("Firmware", value: "v1.0.0")
                        }

                        // Logout
                        Section {
                            Button(role: .destructive) {
                                showingLogoutConfirm = true
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Log Out")
                                    Spacer()
                                }
                            }
                        }
                    }
                } else {
                    Text("No profile loaded.")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Profile")
            .alert("Log Out", isPresented: $showingLogoutConfirm) {
                Button("Log Out", role: .destructive) { userStore.logout() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }

    private func icon(for method: AlertMethod) -> String {
        switch method {
        case .audio:   return "speaker.wave.2"
        case .display: return "display"
        case .haptics: return "iphone.radiowaves.left.and.right"
        }
    }
}