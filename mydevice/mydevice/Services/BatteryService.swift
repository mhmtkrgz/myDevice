//
//  BatteryService.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 27/03/2026.
//

import UIKit
import Combine

protocol BatteryServiceProtocol {
    func batteryInfo() -> String
    func batteryIcon() -> String
    var changePublisher: AnyPublisher<Void, Never> { get }
}

final class BatteryService: BatteryServiceProtocol {
    private let subject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    var changePublisher: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true

        NotificationCenter.default
            .publisher(for: UIDevice.batteryLevelDidChangeNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.subject.send() }
            .store(in: &cancellables)
    }

    deinit {
        UIDevice.current.isBatteryMonitoringEnabled = false
    }

    func batteryInfo() -> String {
        let level = UIDevice.current.batteryLevel
        guard level >= 0 else { return "Unknown" }
        let percentage = Int(level * 100)
        switch UIDevice.current.batteryState {
        case .charging:  return "\(percentage)% (Charging)"
        case .full:      return "100% (Plugged In)"
        case .unplugged: return "\(percentage)%"
        default:         return "\(percentage)%"
        }
    }

    func batteryIcon() -> String {
        let level = UIDevice.current.batteryLevel
        switch UIDevice.current.batteryState {
        case .charging, .full:
            return "battery.100.bolt"
        default:
            let pct = level >= 0 ? Int(level * 100) : 0
            switch pct {
            case 76...: return "battery.100"
            case 51...: return "battery.75"
            case 26...: return "battery.50"
            case 11...: return "battery.25"
            default:    return "battery.0"
            }
        }
    }
}
