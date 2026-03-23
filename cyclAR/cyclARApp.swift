//
//  cyclARApp.swift
//  cyclAR
//
//  Created by Nandini Swami on 11/4/25.
//
import SwiftUI

@main
struct cyclARApp: App {
    @StateObject private var userStore = UserStore.shared

    var body: some Scene {
        WindowGroup {
            if userStore.isLoggedIn {
                MainTabView()
                    .environmentObject(userStore)
            } else {
                LoginView()
                    .environmentObject(userStore)
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Navigate", systemImage: "bicycle")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}
