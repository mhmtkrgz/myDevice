//
//  SettingsView.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 27/03/2026.
//

import SwiftUI
import StoreKit

// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("appearanceMode") private var appearanceMode: String = "System"
    @Environment(\.requestReview) var requestReview

    var currentLanguage: String {
        Locale.current.localizedString(forLanguageCode: Locale.current.language.languageCode?.identifier ?? "en") ?? "English"
    }

    var body: some View {
        List {
            Section("Preferences") {
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Label("App Language", systemImage: "globe")
                        Spacer()
                        Text(currentLanguage).foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)

                Picker(selection: $appearanceMode) {
                    Text("System").tag("System")
                    Text("Light").tag("Light")
                    Text("Dark").tag("Dark")
                } label: {
                    Label("Appearance", systemImage: appearanceMode == "Dark" ? "moon.fill" : "sun.max.fill")
                }
            }

            Section("Support") {
                Button(action: { requestReview() }) {
                    Label("Rate My Device", systemImage: "star.fill")
                }
                .foregroundColor(.primary)

                Link(destination: URL(string: "https://example.com/privacy")!) {
                    Label("Privacy Policy", systemImage: "lock.shield.fill")
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle("Settings")
    }
}
