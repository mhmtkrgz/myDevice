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

    private var currentLanguage: String {
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        return Locale.current.localizedString(forLanguageCode: code) ?? "English"
    }

    private var appearanceIcon: String {
        switch appearanceMode {
        case "Dark":  return "moon.fill"
        case "Light": return "sun.max.fill"
        default:      return "circle.lefthalf.filled"  // System
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        List {
            // MARK: Preferences
            Section("Preferences") {
                // App Language — opens app's page in Settings where Language is listed
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Label("App Language", systemImage: "globe")
                        Spacer()
                        Text(currentLanguage)
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .foregroundStyle(.primary)

                Picker(selection: $appearanceMode) {
                    Text("System").tag("System")
                    Text("Light").tag("Light")
                    Text("Dark").tag("Dark")
                } label: {
                    Label("Appearance", systemImage: appearanceIcon)
                }
            }

            // MARK: Support
            Section("Support") {
                Button { requestReview() } label: {
                    Label {
                        Text("Rate My Device")
                    } icon: {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                    }
                }
                .foregroundStyle(.primary)

                Link(destination: URL(string: "https://example.com/privacy")!) {
                    Label {
                        Text("Privacy Policy")
                    } icon: {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(.blue)
                    }
                }
                .foregroundStyle(.primary)
            }

            // MARK: Version
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text("My Device")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)
                        Text("Version \(appVersion) (\(buildNumber))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Settings")
    }
}
