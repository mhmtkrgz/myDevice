//
//  DeviceServiceProvider.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 27/03/2026.
//

import Foundation
import AdSupport
import AppTrackingTransparency
import UIKit
import CoreTelephony
import Darwin

protocol DeviceServiceProtocol {
    func getIDFA() -> String
    func getATTStatus() -> String
    func getIDFV() -> String
    func getDeviceModelName() -> String
    func getOSDisplay() -> String
    func getLocaleDisplay() -> String
    func getTimezoneDisplay() -> String
    func getSIMInfo() -> [SIMInfo]
}

final class DeviceServiceProvider: DeviceServiceProtocol {

    // MARK: - Identifiers

    func getIDFA() -> String {
        ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }

    func getATTStatus() -> String {
        switch ATTrackingManager.trackingAuthorizationStatus {
        case .authorized:    return "Authorized"
        case .denied:        return "Denied"
        case .notDetermined: return "Not Determined"
        case .restricted:    return "Restricted"
        @unknown default:    return "Unknown"
        }
    }

    func getIDFV() -> String {
        UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
    }

    // MARK: - System
    func getDeviceModelName() -> String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        let identifier = String(cString: machine)
        return Self.modelName(for: identifier)
    }

    func getOSDisplay() -> String {
        "iOS \(UIDevice.current.systemVersion)"
    }

    func getLocaleDisplay() -> String {
        let locale = Locale.current
        let regionCode = locale.region?.identifier ?? ""
        let languageCode = locale.language.languageCode?.identifier.uppercased() ?? ""
        let regionName = locale.localizedString(forRegionCode: regionCode) ?? regionCode
        guard !regionName.isEmpty else { return locale.identifier }
        return "\(regionName) (\(languageCode))"
    }

    func getTimezoneDisplay() -> String {
        let tz = TimeZone.current
        let totalSeconds = tz.secondsFromGMT()
        let hours = totalSeconds / 3600
        let minutes = abs(totalSeconds % 3600) / 60
        let sign = hours >= 0 ? "+" : ""
        let city = tz.identifier.split(separator: "/").last.map(String.init) ?? tz.identifier
        let offset = minutes > 0
            ? "GMT\(sign)\(hours):\(String(format: "%02d", minutes))"
            : "GMT\(sign)\(hours)"
        return "\(offset) (\(city))"
    }

    // MARK: - SIM / Carrier
    func getSIMInfo() -> [SIMInfo] {
        let networkInfo = CTTelephonyNetworkInfo()
        let radioTechs = networkInfo.serviceCurrentRadioAccessTechnology ?? [:]
        guard !radioTechs.isEmpty else { return [] }

        return radioTechs.keys.sorted().enumerated().map { index, key in
            let tech = Self.radioTechLabel(radioTechs[key] ?? "")
            return SIMInfo(index: index + 1, isESIM: index > 0, radioTech: tech)
        }
    }

    // MARK: - Helpers
    private static func radioTechLabel(_ tech: String) -> String {
        switch tech {
        case CTRadioAccessTechnologyNR:                 return "5G"
        case CTRadioAccessTechnologyNRNSA:              return "5G NSA"
        case CTRadioAccessTechnologyLTE:                return "LTE"
        case CTRadioAccessTechnologyeHRPD,
             CTRadioAccessTechnologyCDMAEVDORevA,
             CTRadioAccessTechnologyCDMAEVDORevB,
             CTRadioAccessTechnologyCDMAEVDORev0,
             CTRadioAccessTechnologyHSDPA,
             CTRadioAccessTechnologyHSUPA,
             CTRadioAccessTechnologyWCDMA:              return "3G"
        case CTRadioAccessTechnologyEdge:               return "EDGE"
        case CTRadioAccessTechnologyGPRS,
             CTRadioAccessTechnologyCDMA1x:             return "2G"
        default:                                        return "Active"
        }
    }

    private static func modelName(for identifier: String) -> String {
        let lookup: [String: String] = [
            "iPhone18,1": "iPhone 17 Pro Max",
            "iPhone18,2": "iPhone 17 Pro",
            "iPhone18,3": "iPhone 17 Air",
            "iPhone18,4": "iPhone 17",
            "iPhone17,1": "iPhone 16 Pro Max",
            "iPhone17,2": "iPhone 16 Pro",
            "iPhone17,3": "iPhone 16 Plus",
            "iPhone17,4": "iPhone 16",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone14,5": "iPhone 13",
            "iPhone14,4": "iPhone 13 Mini",
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone13,1": "iPhone 12 Mini",
            "iPhone13,2": "iPhone 12",
            "iPhone13,3": "iPhone 12 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",
            "iPhone14,6": "iPhone SE (3rd gen)",
            "iPhone12,8": "iPhone SE (2nd gen)",
            "iPad14,3":   "iPad Pro 11\" (4th gen)",
            "iPad14,4":   "iPad Pro 11\" (4th gen)",
            "iPad14,5":   "iPad Pro 12.9\" (6th gen)",
            "iPad14,6":   "iPad Pro 12.9\" (6th gen)",
            "iPad16,3":   "iPad Pro 11\" (M4)",
            "iPad16,4":   "iPad Pro 11\" (M4)",
            "iPad16,5":   "iPad Pro 13\" (M4)",
            "iPad16,6":   "iPad Pro 13\" (M4)",
            "iPad13,16":  "iPad Air (5th gen)",
            "iPad13,17":  "iPad Air (5th gen)",
            "iPad14,8":   "iPad Air (M2)",
            "iPad14,9":   "iPad Air (M2)",
            "iPad14,1":   "iPad Mini (6th gen)",
            "iPad14,2":   "iPad Mini (6th gen)",
            "iPad13,18":  "iPad (10th gen)",
            "iPad13,19":  "iPad (10th gen)",
        ]
        if let name = lookup[identifier] { return name }
        if identifier.hasPrefix("iPhone") { return "iPhone" }
        if identifier.hasPrefix("iPad")   { return "iPad" }
        return UIDevice.current.model
    }
}
