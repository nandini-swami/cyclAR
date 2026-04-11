//
//  StepRowView.swift
//  cyclAR
//
//  Created by Nandini Swami on 3/19/26.
//
import SwiftUI
 
struct StepRowView: View {
    let step: DirectionStep
    let isHighlighted: Bool
 
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
 
            // Arrow icon box
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(isHighlighted ? Color.brand : Color.surfaceGray)
                    .frame(width: 38, height: 38)
                Text(arrowEmoji(for: step.simple))
                    .font(.system(size: 16))
            }
 
            // Text block
            VStack(alignment: .leading, spacing: 3) {
                Text(step.streetName.isEmpty ? step.simple : step.streetName)
                    .font(.cyclARSubhead)
                    .foregroundColor(.appBlack)
                    .lineLimit(1)
 
                HStack(spacing: 4) {
                    if !step.streetName.isEmpty {
                        Text(step.simple)
                            .font(.cyclARCaption)
                            .foregroundColor(.textMuted)
                        Text("·")
                            .font(.cyclARCaption)
                            .foregroundColor(Color.borderGray)
                    }
                    Text(step.distanceText)
                        .font(.cyclARCaption)
                        .foregroundColor(isHighlighted ? .brand : .textMuted)
                        .fontWeight(isHighlighted ? .medium : .regular)
                }
            }
 
            Spacer()
 
            // Live sending indicator
            if isHighlighted {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.brand)
                        .frame(width: 5, height: 5)
                    Text("Live")
                        .font(.cyclARCaption)
                        .foregroundColor(.brand)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.brandLight)
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(isHighlighted ? Color.brandLight : Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isHighlighted ? Color.brandMid : Color.borderGray, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.25), value: isHighlighted)
    }
    
//    private func icon(for simple: String) -> String {
//        switch simple {
//        case "LEFT": return "⬅️"
//        case "RIGHT": return "➡️"
//        default: return "⬆️"
//        }
//    }
}
