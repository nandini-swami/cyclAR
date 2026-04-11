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
        HStack(alignment: .top) {
            Text(icon(for: step.simple))
                .font(.title2)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(step.simple)
                    .font(.headline)

                if !step.streetName.isEmpty {
                    Text(step.streetName)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(step.rawInstruction)
                        .foregroundColor(.secondary)
                        .font(.subheadline)

                    Text("→ in \(step.distanceText)")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }

            Spacer()

            if isHighlighted {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundColor(.green)
                    .animateForever()
            }
        }
        .listRowBackground(isHighlighted ? Color.green.opacity(0.1) : Color.clear)
    }

    private func icon(for simple: String) -> String {
        switch simple {
        case "LEFT": return "⬅️"
        case "RIGHT": return "➡️"
        default: return "⬆️"
        }
    }
}
