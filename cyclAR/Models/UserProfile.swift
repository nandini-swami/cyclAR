//
//  UserProfile.swift
//  cyclAR
//
//  Created by Shruti Agarwal on 3/23/26.
//
import Foundation

struct UserProfile: Codable {
    var name: String
    var email: String
    var password: String              // FIX 1: added so login can validate it
    var safetyAlertCoverage: SafetyAlertCoverage
    var alertMethods: [AlertMethod]
}

enum SafetyAlertCoverage: String, Codable, CaseIterable {
    case medAndHigh = "All MED and HIGH danger events"
    case highOnly   = "All HIGH danger events only"
}

enum AlertMethod: String, Codable, CaseIterable {
    case display  = "Display"
    case haptics  = "Haptics"
}

final class UserStore: ObservableObject {
    static let shared = UserStore()
    private let key = "cyclAR_user"

    @Published var currentUser: UserProfile?
    @Published var isLoggedIn: Bool = false

    init() {
        load()
    }

    // FIX 2: register() saves to disk but does NOT log in.
    // Called from SignUpView — user must then log in manually.
    func register(_ profile: UserProfile) {
        currentUser = profile
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // FIX 3: login() checks both email AND password before setting isLoggedIn.
    @discardableResult
    func login(email: String, password: String) -> Bool {
        guard let user = currentUser,
              user.email.lowercased() == email.lowercased(),
              user.password == password else {
            return false
        }
        isLoggedIn = true
        return true
    }

    // FIX 2 cont: logout() only clears the session flag — profile stays on
    // disk so the user can log back in without signing up again.
    func logout() {
        isLoggedIn = false
    }
    
    func updatePreferences(
            safetyAlertCoverage: SafetyAlertCoverage,
            alertMethods: [AlertMethod]
        ) {
            guard var user = currentUser else { return }
            user.safetyAlertCoverage = safetyAlertCoverage
            user.alertMethods = alertMethods
            currentUser = user
            save(user)
        }
    
    private func save(_ profile: UserProfile) {
            if let data = try? JSONEncoder().encode(profile) {
                UserDefaults.standard.set(data, forKey: key)
            }
        }


    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else { return }
        currentUser = profile
        // Do NOT set isLoggedIn = true here — user must log in each session
    }
}
