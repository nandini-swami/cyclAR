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
            ZStack {
                Color.surfaceGray.ignoresSafeArea()
 
                if let user = userStore.currentUser {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
 
                            // ── PROFILE HEADER ────────────────────────
                            ProfileHeader(user: user)
 
                            VStack(spacing: 20) {
 
                                // ── SAFETY ALERTS ─────────────────────
                                SettingsSection(title: "Safety Alert Coverage") {
                                    ForEach(SafetyAlertCoverage.allCases, id: \.self) { option in
                                        Button {
                                            selectedCoverage = option
                                            savePreferences()
                                        } label: {
                                            HStack(spacing: 12) {
                                                Image(systemName: "shield.lefthalf.filled")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.brand)
                                                    .frame(width: 20)
                                                Text(option.rawValue)
                                                    .font(.cyclARBody)
                                                    .foregroundColor(.appBlack)
                                                    .multilineTextAlignment(.leading)
                                                Spacer()
                                                SelectionIndicator(isSelected: selectedCoverage == option)
                                            }
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 12)
                                        }
                                        if option != SafetyAlertCoverage.allCases.last {
                                            Divider().padding(.horizontal, 14)
                                        }
                                    }
                                }
 
                                // ── ALERT METHODS ──────────────────────
                                SettingsSection(title: "Alert Methods") {
                                    ForEach(AlertMethod.allCases, id: \.self) { method in
                                        Button {
                                            handleMethodTap(method)
                                        } label: {
                                            HStack(spacing: 12) {
                                                Image(systemName: methodIcon(for: method))
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.brand)
                                                    .frame(width: 20)
                                                Text(method.rawValue)
                                                    .font(.cyclARBody)
                                                    .foregroundColor(.appBlack)
                                                Spacer()
                                                // Toggle switch style
                                                CyclARToggle(isOn: selectedMethods.contains(method))
                                            }
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 12)
                                        }
                                        if method != AlertMethod.allCases.last {
                                            Divider().padding(.horizontal, 14)
                                        }
                                    }
                                }
 
                                // ── SAVED CONFIRM ──────────────────────
                                if let msg = savedMessage {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12))
                                        Text(msg)
                                            .font(.cyclARCaption)
                                    }
                                    .foregroundColor(Color(hex: "#3B6D11"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 24)
                                    .transition(.opacity)
                                }
 
                                // ── HELMET INFO ────────────────────────
                                SettingsSection(title: "Helmet") {
                                    SettingsInfoRow(label: "Device", value: "cyclAR Helmet")
                                    Divider().padding(.horizontal, 14)
                                    SettingsInfoRow(label: "Firmware", value: "v1.0.0")
                                    Divider().padding(.horizontal, 14)
                                    SettingsInfoRow(
                                        label: "Connection",
                                        value: "Connected",
                                        valueColor: Color(hex: "#3B6D11")
                                    )
                                }
 
                                // ── LOG OUT ────────────────────────────
                                Button {
                                    showingLogoutConfirm = true
                                } label: {
                                    Text("Log Out")
                                        .font(.cyclARSubhead)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.brandDark)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color.brandLight)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.brandMid, lineWidth: 1)
                                        )
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 36)
                            }
                            .padding(.top, 20)
                        }
                    }
                    .onAppear {
                        selectedCoverage = user.safetyAlertCoverage
                        selectedMethods  = Set(user.alertMethods)
                    }
                } else {
                    Text("No profile loaded.")
                        .font(.cyclARBody)
                        .foregroundColor(.textMuted)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 0) {
                        Text("Cycl").font(.cyclARTitle).foregroundColor(.appBlack)
                        Text("AR").font(.cyclARTitle).foregroundColor(.brand)
                    }
                }
            }
            .alert("Log Out", isPresented: $showingLogoutConfirm) {
                Button("Log Out", role: .destructive) { userStore.logout() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to log out?")
            }
            .alert("Turn off all alert feedback?", isPresented: $showingNoAlertsConfirm) {
                Button("Keep One On", role: .cancel) { pendingRemovalMethod = nil }
                Button("Turn Off All Alerts", role: .destructive) {
                    if let method = pendingRemovalMethod {
                        selectedMethods.remove(method)
                        savePreferences()
                    }
                    pendingRemovalMethod = nil
                }
            } message: {
                Text("You will not receive display or haptic alerts for safety events.")
            }
        }
    }
 
    // MARK: - Helpers
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
        let ordered = AlertMethod.allCases.filter { selectedMethods.contains($0) }
        userStore.updatePreferences(safetyAlertCoverage: selectedCoverage, alertMethods: ordered)
        BLEManager.shared.sendConfigUpdate(coverage: selectedCoverage, alertMethods: ordered)
 
        withAnimation {
            savedMessage = "Preferences saved"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { savedMessage = nil }
        }
    }
 
    private func methodIcon(for method: AlertMethod) -> String {
        switch method {
        case .display: return "display"
        case .haptics: return "iphone.radiowaves.left.and.right"
        }
    }
}
 
// MARK: - Profile Header
struct ProfileHeader: View {
    let user: UserProfile
 
    private var initials: String {
        let parts = user.name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first.map { String($0) } }
        return letters.joined().uppercased()
    }
 
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.brand)
                        .frame(width: 52, height: 52)
                    Text(initials)
                        .font(.custom("Lexend-Bold", size: 18))
                        .foregroundColor(.white)
                }
 
                VStack(alignment: .leading, spacing: 3) {
                    Text(user.name)
                        .font(.cyclARHeadline)
                        .foregroundColor(.appBlack)
                    Text(user.email)
                        .font(.cyclARCaption)
                        .foregroundColor(.textMuted)
                }
 
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color.borderGray),
                alignment: .bottom
            )
        }
    }
}
 
// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
 
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeaderLabel(text: title)
                .padding(.horizontal, 24)
 
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
 
// MARK: - Settings Info Row
struct SettingsInfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .textMuted
 
    var body: some View {
        HStack {
            Text(label)
                .font(.cyclARBody)
                .foregroundColor(.appBlack)
            Spacer()
            Text(value)
                .font(.cyclARBody)
                .foregroundColor(valueColor)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}
 
// MARK: - Toggle
struct CyclARToggle: View {
    let isOn: Bool
 
    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(isOn ? Color.brand : Color.borderGray)
                .frame(width: 36, height: 22)
 
            Circle()
                .fill(Color.white)
                .frame(width: 18, height: 18)
                .padding(2)
                .shadow(color: Color.black.opacity(0.12), radius: 1, x: 0, y: 1)
        }
        .animation(.easeInOut(duration: 0.2), value: isOn)
    }
}
