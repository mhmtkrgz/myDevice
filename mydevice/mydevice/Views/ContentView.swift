//
//  ContentView.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 27/03/2026.
//

import SwiftUI

// MARK: - ContentView
struct ContentView: View {
    @StateObject private var viewModel = DeviceVM()
    @AppStorage("appearanceMode") private var appearanceMode: String = "System"
    @State private var showCopyToast = false

    var body: some View {
        NavigationStack {
            List {
                // 1. Identifiers & Privacy
                Section("Identifiers & Privacy") {
                    InfoRow(label: "IDFA", value: viewModel.idfa, icon: "target", color: .red, isTechnical: true)
                    InfoRow(label: "ATT Status", value: viewModel.attStatus, icon: "hand.raised.fill", color: .orange)
                    InfoRow(label: "IDFV", value: viewModel.idfv, icon: "building.2.fill", color: .blue, isTechnical: true)
                }

                // 2. Network Diagnostics
                Section("Network") {
                    InfoRow(label: "Connection", value: "Wi-Fi", icon: "wifi", color: .blue)
                    InfoRow(label: "Local IP", value: "192.168.1.42", icon: "network", color: .teal, isTechnical: true)
                    InfoRow(label: "Carrier", value: "Sky Mobile", icon: "antenna.radiowaves.left.and.right", color: .purple)
                }

                // 3. System Summary
                Section("System Summary") {
                    InfoRow(label: "Device", value: "iPhone 15 Pro", icon: "iphone", color: .primary)
                    InfoRow(label: "iOS", value: "17.4", icon: "apps.iphone", color: .secondary)
                    InfoRow(label: "Locale", value: "United Kingdom (EN)", icon: "map.fill", color: .red)
                    InfoRow(label: "Timezone", value: "GMT+0 (London)", icon: "clock.fill", color: .cyan)
                }

                // 4. Hardware & Storage
                Section("Hardware & Storage") {

                    HStack(spacing: 12) {
                        Image(systemName: "internaldrive.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Storage")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            ProgressView(value: 0.72) {
                                HStack {
                                    Text("72% Used")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("184GB / 256GB").font(.caption2).bold()
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    InfoRow(label: "Battery", value: "85% (Charging)", icon: "battery.100.bolt", color: .green)
                    InfoRow(label: "Display", value: "2556 x 1179 (460 PPI)", icon: "iphone.gen3", color: .gray)
                }
            }
            .navigationTitle("My Device")
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if showCopyToast {
                    ToastView()
                }
            }
        }
    }
}



#Preview {
    ContentView()
}
