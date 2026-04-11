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
    @State private var showingNoAlertsConfirm = false

    @State private var selectedCoverage: SafetyAlertCoverage = .medAndHigh
    @State private var selectedMethods: Set<AlertMethod> = []
    @State private var pendingRemovalMethod: AlertMethod?
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
                                    handleMethodTap(method)
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
                Button("Log Out", role: .destructive) {
                    userStore.logout()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to log out?")
            }
            .alert("Turn off all alert feedback?", isPresented: $showingNoAlertsConfirm) {
                Button("Keep One On", role: .cancel) {
                    pendingRemovalMethod = nil
                }
                Button("Turn Off All Alerts", role: .destructive) {
                    if let method = pendingRemovalMethod {
                        selectedMethods.remove(method)
                        savePreferences()
                    }
                    pendingRemovalMethod = nil
                }
            } message: {
                Text("You have selected no alert feedback. You will not receive display or haptic alerts.")
            }
        }
    }

    private func handleMethodTap(_ method: AlertMethod) {
        if selectedMethods.contains(method) {
            if selectedMethods.count == 1 {
                pendingRemovalMethod = method
                showingNoAlertsConfirm = true
            } else {
                selectedMethods.remove(method)
                savePreferences()
            }
        } else {
            selectedMethods.insert(method)
            savePreferences()
        }
    }

    private func savePreferences() {
        let orderedMethods = AlertMethod.allCases.filter { selectedMethods.contains($0) }
        userStore.updatePreferences(
            safetyAlertCoverage: selectedCoverage,
            alertMethods: orderedMethods
        )
        
        BLEManager.shared.sendConfigUpdate(
                coverage: selectedCoverage,
                alertMethods: orderedMethods
            )

        savedMessage = "Preferences updated"

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            savedMessage = nil
        }
    }

    private func icon(for method: AlertMethod) -> String {
        switch method {
        case .display:
            return "display"
        case .haptics:
            return "iphone.radiowaves.left.and.right"
        }
    }
}
