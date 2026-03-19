//
//  ConnectionStatusBox.swift
//  cyclAR
//
//  Created by Nandini Swami on 3/19/26.
//
import SwiftUI

struct ConnectionStatusBox: View {
    let connectionStatus: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("STATUS")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)

            Text(connectionStatus)
                .font(.caption)
                .foregroundColor(statusColor)
                .lineLimit(2)
        }
        .padding(10)
        .frame(maxWidth: 140, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }

    private var statusColor: Color {
        if connectionStatus.lowercased().contains("success") {
            return .green
        } else if connectionStatus.lowercased().contains("error") || connectionStatus.lowercased().contains("err") {
            return .red
        } else {
            return .gray
        }
    }
}
