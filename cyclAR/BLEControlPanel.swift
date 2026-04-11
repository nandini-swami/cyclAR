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
        VStack(alignment: .leading, spacing: 8) {
            SectionHeaderLabel(text: "Manual Controls")
 
            HStack(spacing: 10) {
                controlButton(label: "← Left",     action: onLeft)
                controlButton(label: "→ Right",    action: onRight)
                controlButton(label: "↑ Straight", action: onUp)
            }
        }
    }
 
    private func controlButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.cyclARSubhead)
                .foregroundColor(.appBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.borderGray, lineWidth: 1.5)
                )
        }
    }
}
