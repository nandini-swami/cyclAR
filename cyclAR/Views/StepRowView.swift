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

    private var isArrivalStep: Bool {
        let lower = step.rawInstruction.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return lower.contains("destination will be on the")
            || lower.contains("you have arrived")
            || lower.contains("arrive at")
    }
 
    var body: some View {
        HStack(alignment: .center, spacing: 12) {

            if !isArrivalStep {
                ZStack {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(isHighlighted ? Color.brand : Color.surfaceGray)
                        .frame(width: 38, height: 38)

                    Text(arrowEmoji(for: step.simple))
                        .font(.system(size: 16))
                        .foregroundColor(isHighlighted ? .white : .textMuted)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(displayTitle(for: step))
                    .font(.cyclARSubhead)
                    .foregroundColor(.appBlack)
                    .lineLimit(isArrivalStep ? nil : 1)
                    .fixedSize(horizontal: false, vertical: true)

                if !isArrivalStep {
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
            }
 
            Spacer()
 
            if isHighlighted && !isArrivalStep {
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
        .padding(.vertical, isArrivalStep ? 14 : 10)
        .background(isHighlighted ? Color.brandLight : Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isHighlighted ? Color.brandMid : Color.borderGray, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.25), value: isHighlighted)
    }
    
    private func displayTitle(for step: DirectionStep) -> String {
        let raw = step.rawInstruction.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = raw.lowercased()

        if lower.contains("destination will be on the") ||
           lower.contains("you have arrived") ||
           lower.contains("arrive at") {
            return raw
        }

        return step.streetName.isEmpty ? step.simple : step.streetName
    }
}
