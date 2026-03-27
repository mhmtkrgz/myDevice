//
//  InfoRow.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 27/03/2026.
//

import SwiftUI

// MARK: - InfoRow
struct InfoRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    var isTechnical: Bool = false

    var body: some View {
        Button(action: {
            UIPasteboard.general.string = value
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            // Toast tetikleme mantığı buraya eklenebilir
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18))
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    Text(value)
                        .font(isTechnical ? .system(.body, design: .monospaced) : .body)
                        .foregroundColor(.primary)
                }
                Spacer()
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .buttonStyle(.plain)
    }
}
