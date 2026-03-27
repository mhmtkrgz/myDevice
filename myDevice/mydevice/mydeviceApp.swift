//
//  mydeviceApp.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 27/03/2026.
//

import SwiftUI
import AppTrackingTransparency

@main
struct mydeviceApp: App {
    @AppStorage("appearanceMode") private var appearanceMode: String = "System"

    var preferredColorScheme: ColorScheme? {
        switch appearanceMode {
        case "Light": return .light
        case "Dark":  return .dark
        default:      return nil  // follows system
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(preferredColorScheme)
                .task {
                    // Request ATT asynchronously — UI is already visible and
                    // fully loaded before the permission dialog appears.
                    _ = await ATTrackingManager.requestTrackingAuthorization()
                    NotificationCenter.default.post(name: .attStatusDidChange, object: nil)
                }
        }
    }
}

extension Notification.Name {
    static let attStatusDidChange = Notification.Name("attStatusDidChange")
}
