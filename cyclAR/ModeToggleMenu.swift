//
//  ModeToggleMenu.swift
//  cyclAR
//
//  Created by Nandini Swami on 3/19/26.
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
                .font(.title3)
                .foregroundColor(.primary)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
        }
    }
}
