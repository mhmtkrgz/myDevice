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
        // Source: https://gist.github.com/adamawolf/3048717
        let lookup: [String: String] = [
            // ── Simulators ────────────────────────────────────────
            "i386":       "iPhone Simulator",
            "x86_64":     "iPhone Simulator",
            "arm64":      "iPhone Simulator",

            // ── iPhone 17 ─────────────────────────────────────────
            "iPhone18,1": "iPhone 17 Pro",
            "iPhone18,2": "iPhone 17 Pro Max",
            "iPhone18,3": "iPhone 17",
            "iPhone18,4": "iPhone Air",

            // ── iPhone 16 ─────────────────────────────────────────
            "iPhone17,1": "iPhone 16 Pro",
            "iPhone17,2": "iPhone 16 Pro Max",
            "iPhone17,3": "iPhone 16",
            "iPhone17,4": "iPhone 16 Plus",
            "iPhone17,5": "iPhone 16e",

            // ── iPhone 15 ─────────────────────────────────────────
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",

            // ── iPhone 14 ─────────────────────────────────────────
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",

            // ── iPhone 13 ─────────────────────────────────────────
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,4": "iPhone 13 Mini",
            "iPhone14,5": "iPhone 13",

            // ── iPhone 12 ─────────────────────────────────────────
            "iPhone13,1": "iPhone 12 Mini",
            "iPhone13,2": "iPhone 12",
            "iPhone13,3": "iPhone 12 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",

            // ── iPhone 11 ─────────────────────────────────────────
            "iPhone12,1": "iPhone 11",
            "iPhone12,3": "iPhone 11 Pro",
            "iPhone12,5": "iPhone 11 Pro Max",

            // ── iPhone X / XS / XR ────────────────────────────────
            "iPhone11,2": "iPhone XS",
            "iPhone11,4": "iPhone XS Max",
            "iPhone11,6": "iPhone XS Max",
            "iPhone11,8": "iPhone XR",
            "iPhone10,3": "iPhone X",
            "iPhone10,6": "iPhone X",

            // ── iPhone 8 / 7 / 6s / 6 ────────────────────────────
            "iPhone10,1": "iPhone 8",
            "iPhone10,2": "iPhone 8 Plus",
            "iPhone10,4": "iPhone 8",
            "iPhone10,5": "iPhone 8 Plus",
            "iPhone9,1":  "iPhone 7",
            "iPhone9,2":  "iPhone 7 Plus",
            "iPhone9,3":  "iPhone 7",
            "iPhone9,4":  "iPhone 7 Plus",
            "iPhone8,1":  "iPhone 6s",
            "iPhone8,2":  "iPhone 6s Plus",
            "iPhone7,1":  "iPhone 6 Plus",
            "iPhone7,2":  "iPhone 6",

            // ── iPhone SE ─────────────────────────────────────────
            "iPhone14,6": "iPhone SE (3rd gen)",
            "iPhone12,8": "iPhone SE (2nd gen)",
            "iPhone8,4":  "iPhone SE",

            // ── iPhone 5 / 4 / older ──────────────────────────────
            "iPhone6,1":  "iPhone 5s",
            "iPhone6,2":  "iPhone 5s",
            "iPhone5,1":  "iPhone 5",
            "iPhone5,2":  "iPhone 5",
            "iPhone5,3":  "iPhone 5C",
            "iPhone5,4":  "iPhone 5C",
            "iPhone4,1":  "iPhone 4S",
            "iPhone3,1":  "iPhone 4",
            "iPhone3,2":  "iPhone 4",
            "iPhone3,3":  "iPhone 4",
            "iPhone2,1":  "iPhone 3GS",
            "iPhone1,2":  "iPhone 3G",
            "iPhone1,1":  "iPhone",

            // ── iPad Pro ──────────────────────────────────────────
            "iPad16,3":   "iPad Pro 11\" (M4, WiFi)",
            "iPad16,4":   "iPad Pro 11\" (M4, WiFi+Cellular)",
            "iPad16,5":   "iPad Pro 12.9\" (M4, WiFi)",
            "iPad16,6":   "iPad Pro 12.9\" (M4, WiFi+Cellular)",
            "iPad14,3":   "iPad Pro 11\" (4th gen, WiFi)",
            "iPad14,4":   "iPad Pro 11\" (4th gen, WiFi+Cellular)",
            "iPad14,5":   "iPad Pro 12.9\" (6th gen, WiFi)",
            "iPad14,6":   "iPad Pro 12.9\" (6th gen, WiFi+Cellular)",
            "iPad13,4":   "iPad Pro 11\" (5th gen)",
            "iPad13,5":   "iPad Pro 11\" (5th gen)",
            "iPad13,6":   "iPad Pro 11\" (5th gen)",
            "iPad13,7":   "iPad Pro 11\" (5th gen)",
            "iPad13,8":   "iPad Pro 12.9\" (5th gen)",
            "iPad13,9":   "iPad Pro 12.9\" (5th gen)",
            "iPad13,10":  "iPad Pro 12.9\" (5th gen)",
            "iPad13,11":  "iPad Pro 12.9\" (5th gen)",
            "iPad8,9":    "iPad Pro 11\" (4th gen, WiFi)",
            "iPad8,10":   "iPad Pro 11\" (4th gen, WiFi+Cellular)",
            "iPad8,11":   "iPad Pro 12.9\" (4th gen, WiFi)",
            "iPad8,12":   "iPad Pro 12.9\" (4th gen, WiFi+Cellular)",
            "iPad8,1":    "iPad Pro 11\" (3rd gen, WiFi)",
            "iPad8,2":    "iPad Pro 11\" (3rd gen, 1TB, WiFi)",
            "iPad8,3":    "iPad Pro 11\" (3rd gen, WiFi+Cellular)",
            "iPad8,4":    "iPad Pro 11\" (3rd gen, 1TB, WiFi+Cellular)",
            "iPad8,5":    "iPad Pro 12.9\" (3rd gen, WiFi)",
            "iPad8,6":    "iPad Pro 12.9\" (3rd gen, 1TB, WiFi)",
            "iPad8,7":    "iPad Pro 12.9\" (3rd gen, WiFi+Cellular)",
            "iPad8,8":    "iPad Pro 12.9\" (3rd gen, 1TB, WiFi+Cellular)",
            "iPad7,1":    "iPad Pro 12.9\" (2nd gen, WiFi)",
            "iPad7,2":    "iPad Pro 12.9\" (2nd gen, WiFi+Cellular)",
            "iPad7,3":    "iPad Pro 10.5\"",
            "iPad7,4":    "iPad Pro 10.5\"",
            "iPad6,3":    "iPad Pro 9.7\"",
            "iPad6,4":    "iPad Pro 9.7\"",
            "iPad6,7":    "iPad Pro 12.9\"",
            "iPad6,8":    "iPad Pro 12.9\"",

            // ── iPad Air ──────────────────────────────────────────
            "iPad15,3":   "iPad Air 11\" (7th gen, WiFi)",
            "iPad15,4":   "iPad Air 11\" (7th gen, WiFi+Cellular)",
            "iPad15,5":   "iPad Air 13\" (7th gen, WiFi)",
            "iPad15,6":   "iPad Air 13\" (7th gen, WiFi+Cellular)",
            "iPad14,8":   "iPad Air 11\" (6th gen, WiFi)",
            "iPad14,9":   "iPad Air 11\" (6th gen, WiFi+Cellular)",
            "iPad14,10":  "iPad Air 13\" (6th gen, WiFi)",
            "iPad14,11":  "iPad Air 13\" (6th gen, WiFi+Cellular)",
            "iPad13,16":  "iPad Air (5th gen, WiFi)",
            "iPad13,17":  "iPad Air (5th gen, WiFi+Cellular)",
            "iPad13,1":   "iPad Air (4th gen, WiFi)",
            "iPad13,2":   "iPad Air (4th gen, WiFi+Cellular)",
            "iPad11,3":   "iPad Air (3rd gen, WiFi)",
            "iPad11,4":   "iPad Air (3rd gen, WiFi+Cellular)",
            "iPad5,3":    "iPad Air 2 (WiFi)",
            "iPad5,4":    "iPad Air 2 (Cellular)",
            "iPad4,1":    "iPad Air (WiFi)",
            "iPad4,2":    "iPad Air (GSM+CDMA)",
            "iPad4,3":    "iPad Air (China)",

            // ── iPad mini ─────────────────────────────────────────
            "iPad16,1":   "iPad mini (7th gen, WiFi)",
            "iPad16,2":   "iPad mini (7th gen, WiFi+Cellular)",
            "iPad14,1":   "iPad mini (6th gen, WiFi)",
            "iPad14,2":   "iPad mini (6th gen, WiFi+Cellular)",
            "iPad11,1":   "iPad mini (5th gen, WiFi)",
            "iPad11,2":   "iPad mini (5th gen, WiFi+Cellular)",
            "iPad5,1":    "iPad mini 4 (WiFi)",
            "iPad5,2":    "iPad mini 4 (WiFi+Cellular)",
            "iPad4,7":    "iPad mini 3 (WiFi)",
            "iPad4,8":    "iPad mini 3 (GSM+CDMA)",
            "iPad4,9":    "iPad mini 3 (China)",
            "iPad4,4":    "iPad mini Retina (WiFi)",
            "iPad4,5":    "iPad mini Retina (GSM+CDMA)",
            "iPad4,6":    "iPad mini Retina (China)",
            "iPad2,5":    "iPad mini (WiFi)",
            "iPad2,6":    "iPad mini (GSM+LTE)",
            "iPad2,7":    "iPad mini (CDMA+LTE)",

            // ── iPad (standard) ───────────────────────────────────
            "iPad15,7":   "iPad (11th gen, WiFi)",
            "iPad15,8":   "iPad (11th gen, WiFi+Cellular)",
            "iPad13,18":  "iPad (10th gen, WiFi)",
            "iPad13,19":  "iPad (10th gen, WiFi+Cellular)",
            "iPad12,1":   "iPad (9th gen, WiFi)",
            "iPad12,2":   "iPad (9th gen, WiFi+Cellular)",
            "iPad11,6":   "iPad (8th gen, WiFi)",
            "iPad11,7":   "iPad (8th gen, WiFi+Cellular)",
            "iPad7,11":   "iPad (7th gen, WiFi)",
            "iPad7,12":   "iPad (7th gen, WiFi+Cellular)",
            "iPad7,5":    "iPad (6th gen, WiFi)",
            "iPad7,6":    "iPad (6th gen, WiFi+Cellular)",
            "iPad6,11":   "iPad (2017)",
            "iPad6,12":   "iPad (2017)",
            "iPad3,4":    "iPad (4th gen)",
            "iPad3,5":    "iPad (4th gen)",
            "iPad3,6":    "iPad (4th gen)",
            "iPad3,1":    "iPad (3rd gen)",
            "iPad3,2":    "iPad (3rd gen)",
            "iPad3,3":    "iPad (3rd gen)",
            "iPad2,1":    "iPad 2 (WiFi)",
            "iPad2,2":    "iPad 2 (GSM)",
            "iPad2,3":    "iPad 2 (CDMA)",
            "iPad2,4":    "iPad 2",
            "iPad1,1":    "iPad",
            "iPad1,2":    "iPad 3G",
        ]
        if let name = lookup[identifier] { return name }
        if identifier.hasPrefix("iPhone") { return "iPhone" }
        if identifier.hasPrefix("iPad")   { return "iPad" }
        return UIDevice.current.model
    }
}
