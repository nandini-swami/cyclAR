//
//  MainTabView.swift
//  cyclAR
//
//  Created by Nandini Swami on 4/11/26.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userStore: UserStore

    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Navigate", systemImage: "location.fill")
                }

            DemoView()
                .tabItem {
                    Label("Demo", systemImage: "play.rectangle.fill")
                }

            ProfileView()
                .environmentObject(userStore)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(.brand)
        .onAppear {
            // Style the tab bar
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.white
            appearance.shadowColor = UIColor(Color.borderGray)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
