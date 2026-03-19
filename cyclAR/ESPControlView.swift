//
//  ESPControlView.swift
//  cyclAR
//
//  Created by Nandini Swami on 3/19/26.
//
import SwiftUI

struct ESPControlPanel: View {
    let espIP: String
    let connectionStatus: String
    let onLeft: () -> Void
    let onRight: () -> Void
    let onUp: () -> Void

    var body: some View {
        VStack {
            Text("ESP32 IP: \(espIP)")
                .font(.caption2)
                .foregroundColor(.gray)

            Text("Status: \(connectionStatus)")
                .font(.caption)
                .foregroundColor(connectionStatus.contains("Success") ? .green : .gray)
                .padding(.bottom, 5)

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
