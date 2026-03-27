//
//  InfoRow.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 27/03/2026.
//

import SwiftUI

// MARK: - Environment key for copy-tap feedback
private struct OnCopyKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var onCopy: () -> Void {
        get { self[OnCopyKey.self] }
        set { self[OnCopyKey.self] = newValue }
    }
}

// MARK: - InfoRow
struct InfoRow: View {
    let label: LocalizedStringKey
    let value: String
    let icon: String
    let color: Color
    var isTechnical: Bool = false
    var showCopyIcon: Bool = true

    @Environment(\.onCopy) private var onCopy

    var body: some View {
        Button(action: {
            guard showCopyIcon else { return }
            UIPasteboard.general.string = value
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onCopy()
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
                if showCopyIcon {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.5))
                }
            }
        }
        .buttonStyle(.plain)
    }
}
