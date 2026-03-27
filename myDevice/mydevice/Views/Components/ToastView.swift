//
//  ToastView.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 27/03/2026.
//

import SwiftUI

// MARK: - ToastView
struct ToastView: View {
    var body: some View {
        Text("Copied")
            .font(.subheadline).bold()
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color.primary.opacity(0.9)))
            .foregroundColor(Color(UIColor.systemBackground))
            .padding(.bottom, 30)
    }
}
