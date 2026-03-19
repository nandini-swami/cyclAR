//
//  ModeBadge.swift
//  cyclAR
//
//  Created by Nandini Swami on 3/19/26.
//


import SwiftUI

struct ModeBadge: View {
    let demoMode: Bool

    var body: some View {
        Text(demoMode ? "DEMO" : "LIVE")
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(demoMode ? Color.orange.opacity(0.18) : Color.green.opacity(0.18))
            )
            .foregroundColor(demoMode ? .orange : .green)
    }
}
