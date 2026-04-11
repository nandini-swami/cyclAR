//  Created by Nandini Swami on 3/19/26.
//
//
//  ConnectionStatusBox.swift
//  cyclAR
//
//  Kept for compatibility — the status pill is now embedded directly
//  in CyclARNavBar inside ContentView. This view is no longer used
//  in the main layout but is preserved here in case it's referenced
//  elsewhere in the project.
//
 
import SwiftUI
 
struct ConnectionStatusBox: View {
    let connectionStatus: String
 
    private var isConnected: Bool {
        connectionStatus.lowercased().contains("connect") &&
        !connectionStatus.lowercased().contains("not")
    }
    private var isError: Bool {
        connectionStatus.lowercased().contains("error") ||
        connectionStatus.lowercased().contains("err")
    }
 
    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(dotColor)
                .frame(width: 6, height: 6)
            Text(connectionStatus)
                .font(.cyclARCaption)
                .foregroundColor(labelColor)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }
 
    private var dotColor: Color {
        if isConnected { return Color(hex: "#3B6D11") }
        if isError     { return .brand }
        return .textMuted
    }
    private var labelColor: Color {
        if isConnected { return Color(hex: "#3B6D11") }
        if isError     { return .brand }
        return .textMuted
    }
}
