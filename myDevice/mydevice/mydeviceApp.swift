//
//  mydeviceApp.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 27/03/2026.
//

import SwiftUI
import AppTrackingTransparency
import Firebase
import AMRSDK

@main
struct mydeviceApp: App {
    @AppStorage("appearanceMode") private var appearanceMode: String = "System"
    @State private var showSplash = true

    init() {
        FirebaseApp.configure()
        AMRSDK.start(withAppId: "74a99ca3-b483-4d0f-b765-d0e1bcf59650")
    }

    var preferredColorScheme: ColorScheme? {
        switch appearanceMode {
        case "Light": return .light
        case "Dark":  return .dark
        default:      return nil  // follows system
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .preferredColorScheme(preferredColorScheme)
                    .task {
                        _ = await ATTrackingManager.requestTrackingAuthorization()
                        NotificationCenter.default.post(name: .attStatusDidChange, object: nil)
                    }

                if showSplash {
                    SplashView()
                        .preferredColorScheme(preferredColorScheme)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .animation(.easeOut(duration: 0.4), value: showSplash)
            .task {
                try? await Task.sleep(for: .seconds(1.5))
                showSplash = false
            }
        }
    }
}

extension Notification.Name {
    static let attStatusDidChange = Notification.Name("attStatusDidChange")
}
