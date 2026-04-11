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

    @State private var selectedCoverage: SafetyAlertCoverage = .medAndHigh
    @State private var selectedMethods: Set<AlertMethod> = []
    @State private var savedMessage: String?

    var body: some View {
        NavigationView {
            Group {
                if let user = userStore.currentUser {
                    Form {
                        Section(header: Text("Account")) {
                            LabeledContent("Name", value: user.name)
                            LabeledContent("Email", value: user.email)
                        }

                        Section(header: Text("Road Safety Alert Coverage")) {
                            ForEach(SafetyAlertCoverage.allCases, id: \.self) { option in
                                HStack {
                                    Image(systemName: "shield.lefthalf.filled")
                                        .foregroundColor(.orange)

                                    Text(option.rawValue)

                                    Spacer()

                                    if selectedCoverage == option {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedCoverage = option
                                    savePreferences()
                                }
                            }
                        }

                        Section(header: Text("Alert Methods")) {
                            ForEach(AlertMethod.allCases, id: \.self) { method in
                                HStack {
                                    Image(systemName: icon(for: method))
                                        .foregroundColor(.green)
                                        .frame(width: 24)

                                    Text(method.rawValue)

                                    Spacer()

                                    if selectedMethods.contains(method) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if selectedMethods.contains(method) {
                                        // prevent removing the last method
                                        if selectedMethods.count > 1 {
                                            selectedMethods.remove(method)
                                            savePreferences()
                                        }
                                    } else {
                                        selectedMethods.insert(method)
                                        savePreferences()
                                    }
                                }
                            }
                        }

                        if let savedMessage {
                            Section {
                                Text(savedMessage)
                                    .foregroundColor(.green)
                                    .font(.caption)
                            }
                        }

                        Section(header: Text("Helmet")) {
                            LabeledContent("Connection", value: "cyclAR Helmet")
                            LabeledContent("Firmware", value: "v1.0.0")
                        }

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
                    .onAppear {
                        selectedCoverage = user.safetyAlertCoverage
                        selectedMethods = Set(user.alertMethods)
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

    private func savePreferences() {
        guard !selectedMethods.isEmpty else { return }

        userStore.updatePreferences(
            safetyAlertCoverage: selectedCoverage,
            alertMethods: Array(selectedMethods)
        )

        savedMessage = "Preferences updated"

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            savedMessage = nil
        }
    }

    private func icon(for method: AlertMethod) -> String {
        switch method {
        case .audio:
            return "speaker.wave.2"
        case .display:
            return "display"
        case .haptics:
            return "iphone.radiowaves.left.and.right"
        }
    }
}
