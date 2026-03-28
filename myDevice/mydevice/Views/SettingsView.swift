//
//  SettingsView.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 27/03/2026.
//

import SwiftUI
import StoreKit
import MessageUI

// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("appearanceMode") private var appearanceMode: String = "System"
    @Environment(\.requestReview) var requestReview
    @State private var showMailOptions = false
    @State private var showMailCompose = false
    @State private var showCopiedAlert = false

    private let supportEmail = "support@mehmetkaragoz.com"

    private var deviceInfoBody: String {
        let device = UIDevice.current
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return """


---
Device: \(DeviceServiceProvider().getDeviceModelName())
iOS: \(device.systemVersion)
App Version: \(appVersion) (\(buildNumber))
Language: \(Locale.current.language.languageCode?.identifier.uppercased() ?? "?")
"""
    }

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

                Button {
                    showMailOptions = true
                } label: {
                    Label {
                        Text("Contact")
                    } icon: {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.green)
                    }
                }
                .foregroundStyle(.primary)
                .confirmationDialog("Contact Support", isPresented: $showMailOptions, titleVisibility: .visible) {
                    if MFMailComposeViewController.canSendMail() {
                        Button("Apple Mail") { showMailCompose = true }
                    }
                    if let encoded = deviceInfoBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                       let url = URL(string: "googlegmail://co?to=\(supportEmail)&body=\(encoded)"),
                       UIApplication.shared.canOpenURL(url) {
                        Button("Gmail") { UIApplication.shared.open(url) }
                    }
                    if let encoded = deviceInfoBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                       let url = URL(string: "ymail://mail/compose?to=\(supportEmail)&body=\(encoded)"),
                       UIApplication.shared.canOpenURL(url) {
                        Button("Yahoo Mail") { UIApplication.shared.open(url) }
                    }
                    if let encoded = deviceInfoBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                       let url = URL(string: "ms-outlook://compose?to=\(supportEmail)&body=\(encoded)"),
                       UIApplication.shared.canOpenURL(url) {
                        Button("Outlook") { UIApplication.shared.open(url) }
                    }
                    if let encoded = deviceInfoBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                       let url = URL(string: "readdle-spark://compose?recipient=\(supportEmail)&body=\(encoded)"),
                       UIApplication.shared.canOpenURL(url) {
                        Button("Spark") { UIApplication.shared.open(url) }
                    }
                    if let encoded = deviceInfoBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                       let url = URL(string: "mailto:\(supportEmail)?body=\(encoded)"),
                       !MFMailComposeViewController.canSendMail(),
                       UIApplication.shared.canOpenURL(url) {
                        Button("Mail") { UIApplication.shared.open(url) }
                    }
                    Button("Copy Email Address") {
                        UIPasteboard.general.string = supportEmail
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showCopiedAlert = true
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text(supportEmail)
                }
                .sheet(isPresented: $showMailCompose) {
                    MailComposeView(recipient: supportEmail, body: deviceInfoBody)
                }
                .alert("Email Copied", isPresented: $showCopiedAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(supportEmail)
                }

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
