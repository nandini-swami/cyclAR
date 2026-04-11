//
//  ModeToggleMenu.swift
//  cyclAR
//
//  Created by Nandini Swami on 3/19/26.
//  No longer used — switching between live and demo is now handled by
//  the tab bar in MainTabView. Kept here to avoid breaking any other
//  references in the project.
//
 
import SwiftUI
 
struct ModeToggleMenu: View {
    @Binding var demoMode: Bool
    let onModeChange: (Bool) -> Void
 
    var body: some View {
        Menu {
            Button {
                demoMode = false
                onModeChange(false)
            } label: {
                Label("Live Mode", systemImage: demoMode ? "circle" : "checkmark.circle.fill")
            }
            Button {
                demoMode = true
                onModeChange(true)
            } label: {
                Label("Demo Mode", systemImage: demoMode ? "checkmark.circle.fill" : "circle")
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 15))
                .foregroundColor(.appBlack)
                .padding(9)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.borderGray, lineWidth: 1)
                )
        }
    }
}
 
