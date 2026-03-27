//
//  ATTPermissionBannerView.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 27/03/2026.
//

import SwiftUI

enum ATTWarningState {
    case none          // authorized — no banner shown
    case requestable   // notDetermined — can request in-app
    case denied        // denied / restricted — must go to Settings
}

struct ATTPermissionBannerView: View {
    let state: ATTWarningState
    let onRequest: () async -> Void

    var body: some View {
        switch state {
        case .none:
            EmptyView()

        case .requestable:
            banner(
                icon: "hand.raised.fill",
                tint: .orange,
                title: "Permission Required",
                message: "Allow tracking permission to display your real IDFA.",
                buttonTitle: "Request Permission",
                action: { await onRequest() }
            )

        case .denied:
            banner(
                icon: "exclamationmark.shield.fill",
                tint: .red,
                title: "Access Denied",
                message: "IDFA is unavailable. Open Settings to enable tracking for this app.",
                buttonTitle: "Open Settings",
                action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            )
        }
    }

    @ViewBuilder
    private func banner(
        icon: String,
        tint: Color,
        title: LocalizedStringKey,
        message: LocalizedStringKey,
        buttonTitle: LocalizedStringKey,
        action: @escaping () async -> Void
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(tint)
                .frame(width: 28)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(tint)

                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    Task { await action() }
                } label: {
                    Text(buttonTitle)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(tint.opacity(0.12))
                        .foregroundStyle(tint)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 6)
    }
}
