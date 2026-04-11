//
//  ModeBadge.swift
//  cyclAR
//
//  Created by Nandini Swami on 3/19/26.
//
//  No longer used in the main layout — mode is indicated by the DEMO pill
//  in CyclARNavBar and by DemoView being its own tab. Kept here in case
//  it's referenced elsewhere.
//
 
import SwiftUI
 
struct ModeBadge: View {
    let demoMode: Bool
 
    var body: some View {
        Text(demoMode ? "DEMO" : "LIVE")
            .font(.cyclARLabel)
            .tracking(0.5)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(demoMode
                          ? Color(hex: "#FFF3CD")
                          : Color(hex: "#EAF3DE"))
            )
            .foregroundColor(demoMode
                             ? Color(hex: "#856404")
                             : Color(hex: "#3B6D11"))
    }
}
