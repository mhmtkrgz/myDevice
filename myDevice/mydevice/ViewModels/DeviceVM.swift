//
//  DeviceVM.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 27/03/2026.
//

import Foundation
import Combine
import UIKit

final class DeviceVM: ObservableObject {
    // MARK: - Identifiers
    @Published var idfa: String = ""
    @Published var attStatus: String = ""
    @Published var idfv: String = ""

    // MARK: - Network
    @Published var connectionType: String = "Unknown"
    @Published var localIP: String = "Unknown"
    @Published var simCards: [SIMInfo] = []

    // MARK: - System
    @Published var deviceModel: String = ""
    @Published var osVersion: String = ""
    @Published var locale: String = ""
    @Published var timezone: String = ""

    // MARK: - Hardware
    @Published var battery: String = ""
    @Published var batteryIcon: String = "battery.100"
    @Published var storageUsed: Int64 = 0
    @Published var storageTotal: Int64 = 0
    @Published var displayResolution: String = ""

    // MARK: - Computed Storage Formatting
    var storagePercentage: Double {
        guard storageTotal > 0 else { return 0 }
        return Double(storageUsed) / Double(storageTotal)
    }

    var storageUsedLabel: String {
        guard storageTotal > 0 else { return "Calculating..." }
        return "\(Int(storagePercentage * 100))% Used"
    }

    var storageDetailLabel: String {
        guard storageTotal > 0 else { return "" }
        let fmt = ByteCountFormatter()
        fmt.countStyle = .decimal
        fmt.allowedUnits = [.useGB]
        fmt.includesUnit = true
        let used = fmt.string(fromByteCount: storageUsed)
        let total = fmt.string(fromByteCount: storageTotal)
        return "\(used) / \(total)"
    }

    // MARK: - Services
    private let deviceService: DeviceServiceProtocol
    private let batteryService: BatteryServiceProtocol
    private let networkService: NetworkServiceProtocol
    private let hardwareService: HardwareServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        deviceService: DeviceServiceProtocol = DeviceServiceProvider(),
        batteryService: BatteryServiceProtocol = BatteryService(),
        networkService: NetworkServiceProtocol = NetworkService(),
        hardwareService: HardwareServiceProtocol = HardwareService()
    ) {
        self.deviceService = deviceService
        self.batteryService = batteryService
        self.networkService = networkService
        self.hardwareService = hardwareService

        loadData()
        subscribeToBatteryUpdates()
        subscribeToNetworkUpdates()
    }

    // MARK: - Public
    func refreshData() {
        idfa = deviceService.getIDFA()
        attStatus = deviceService.getATTStatus()
        idfv = deviceService.getIDFV()
        updateBattery()
        updateNetwork()
        simCards = deviceService.getSIMInfo()
    }

    // MARK: - Private
    private func loadData() {
        idfa = deviceService.getIDFA()
        attStatus = deviceService.getATTStatus()
        idfv = deviceService.getIDFV()

        deviceModel = deviceService.getDeviceModelName()
        osVersion = deviceService.getOSDisplay()
        locale = deviceService.getLocaleDisplay()
        timezone = deviceService.getTimezoneDisplay()

        simCards = deviceService.getSIMInfo()

        updateBattery()
        updateNetwork()

        if let (used, total) = hardwareService.storageTuple() {
            storageUsed = used
            storageTotal = total
        }
        displayResolution = hardwareService.displayResolution()
    }

    private func subscribeToBatteryUpdates() {
        batteryService.changePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.updateBattery() }
            .store(in: &cancellables)
    }

    private func subscribeToNetworkUpdates() {
        networkService.pathPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.updateNetwork() }
            .store(in: &cancellables)
    }

    private func updateBattery() {
        battery = batteryService.batteryInfo()
        batteryIcon = batteryService.batteryIcon()
    }

    private func updateNetwork() {
        connectionType = networkService.connectionType()
        localIP = networkService.localIP()
    }
}
