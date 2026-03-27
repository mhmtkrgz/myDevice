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
                    InfoRow(label: "Connection", value: viewModel.connectionType, icon: "wifi", color: .blue)
                    InfoRow(label: "Local IP", value: viewModel.localIP, icon: "network", color: .teal, isTechnical: true)
                    ForEach(viewModel.simCards) { sim in
                        InfoRow(label: sim.label, value: sim.value, icon: sim.icon, color: .purple)
                    }
                }

                // 3. System Summary
                Section("System Summary") {
                    InfoRow(label: "Device", value: viewModel.deviceModel, icon: "iphone", color: .primary)
                    InfoRow(label: "iOS", value: viewModel.osVersion, icon: "apps.iphone", color: .secondary)
                    InfoRow(label: "Locale", value: viewModel.locale, icon: "map.fill", color: .red)
                    InfoRow(label: "Timezone", value: viewModel.timezone, icon: "clock.fill", color: .cyan)
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
                            ProgressView(value: viewModel.storagePercentage) {
                                HStack {
                                    Text(viewModel.storageUsedLabel)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(viewModel.storageDetailLabel)
                                        .font(.caption2)
                                        .bold()
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    InfoRow(label: "Battery", value: viewModel.battery, icon: viewModel.batteryIcon, color: .green)
                    InfoRow(label: "Display", value: viewModel.displayResolution, icon: "iphone.gen3", color: .gray)
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
