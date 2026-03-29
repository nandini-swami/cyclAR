//
//  ESPControlView.swift
//  cyclAR
//
//  Created by Nandini Swami on 3/19/26.
//
import SwiftUI

struct BLEControlPanel: View {
    let onLeft: () -> Void
    let onRight: () -> Void
    let onUp: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Demo Controls")
                .font(.headline)

            Button("Turn left", action: onLeft)
                .buttonStyle(.bordered)
                .tint(.green)

            Button("Turn right", action: onRight)
                .buttonStyle(.bordered)
                .tint(.green)

            Button("Go Straight", action: onUp)
                .buttonStyle(.bordered)
                .tint(.green)
        }
        .padding(.bottom, 20)
    }
}
