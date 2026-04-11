//
//  CyclarNavBar.swift
//  cyclAR
//
//  Created by Nandini Swami on 4/11/26.
//

import SwiftUI
 
struct CyclARNavBar: View {
    let connectionStatus: String
    let demoMode: Bool
 
    private var isConnected: Bool {
        connectionStatus.lowercased().contains("connect") &&
        !connectionStatus.lowercased().contains("not")
    }
 
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
 
            // Logo
            HStack(spacing: 0) {
                Text("Cycl")
                    .font(.cyclARLogoFont)
                    .foregroundColor(.appBlack)
                Text("AR")
                    .font(.cyclARLogoFont)
                    .foregroundColor(.brand)
            }
 
            // Demo pill — only visible in DemoView
            if demoMode {
                Text("DEMO")
                    .font(.cyclARLabel)
                    .tracking(0.5)
                    .foregroundColor(Color(hex: "#856404"))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color(hex: "#FFF3CD"))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "#FFE69C"), lineWidth: 1)
                    )
            }
 
            Spacer()
 
            // Connection status pill
            HStack(spacing: 5) {
                Circle()
                    .fill(isConnected ? Color(hex: "#3B6D11") : Color.textMuted)
                    .frame(width: 6, height: 6)
                Text(isConnected ? "Helmet Connected" : "Not Connected")
                    .font(.cyclARCaption)
                    .foregroundColor(isConnected ? Color(hex: "#3B6D11") : .textMuted)
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
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.borderGray),
            alignment: .bottom
        )
    }
}
 
// MARK: - Route Input Row (shared by ContentView + DemoView)
struct RouteInputRow: View {
    let icon: String
    let iconColor: Color
    let placeholder: String
    @Binding var text: String
    var onChanged: ((String) -> Void)? = nil
 
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(iconColor)
                .frame(width: 20)
            TextField(placeholder, text: $text)
                .font(.cyclARBody)
                .foregroundColor(.appBlack)
                .onChange(of: text) { newVal in onChanged?(newVal) }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.borderGray, lineWidth: 1.5)
        )
    }
}
 
// MARK: - Live Nav Banner (shared by ContentView + DemoView)
struct LiveNavBanner: View {
    let step: DirectionStep
 
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.brand)
                    .frame(width: 48, height: 48)
                Text(arrowEmoji(for: step.simple))
                    .font(.system(size: 22))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(step.streetName.isEmpty ? step.simple : step.streetName)
                    .font(.cyclARHeadline)
                    .foregroundColor(.white)
                HStack(spacing: 6) {
                    Text(step.simple)
                        .font(.cyclARCaption)
                        .foregroundColor(Color.white.opacity(0.6))
                    Text("·")
                        .foregroundColor(Color.white.opacity(0.3))
                    Text(step.distanceText)
                        .font(.cyclARCaption)
                        .foregroundColor(Color.white.opacity(0.7))
                    Text("·")
                        .foregroundColor(Color.white.opacity(0.3))
                    Text("Sending to visor")
                        .font(.cyclARCaption)
                        .foregroundColor(Color.brand.opacity(0.85))
                }
            }
            Spacer()
        }
        .padding(14)
        .background(Color.appBlack)
        .cornerRadius(14)
    }
}
 
// Arrow helper (shared everywhere)
func arrowEmoji(for simple: String) -> String {
    let s = simple.uppercased()
    if s.contains("UTURN") || s.contains("U-TURN") { return "↩" }
    if s.contains("SLIGHT RIGHT")                  { return "↗" }
    if s.contains("SLIGHT LEFT")                   { return "↖" }
    if s.contains("RIGHT")                          { return "→" }
    if s.contains("LEFT")                           { return "←" }
    return "↑"
}
