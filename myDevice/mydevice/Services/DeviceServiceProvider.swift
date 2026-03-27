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

protocol DeviceServiceProtocol {
    func getIDFA() -> String
    func getATTStatus() -> String
    func getIDFV() -> String
    func getDeviceModel() -> String
    func getOSVersion() -> String
}

final class DeviceServiceProvider: DeviceServiceProtocol {
    func getIDFA() -> String {
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }

    func getATTStatus() -> String {
        switch ATTrackingManager.trackingAuthorizationStatus {
        case .authorized: return "Authorized"
        case .denied: return "Denied"
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        @unknown default: return "Unknown"
        }
    }

    func getIDFV() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
    }

    func getDeviceModel() -> String {
        return UIDevice.current.model
    }

    func getOSVersion() -> String {
        return UIDevice.current.systemVersion
    }
}
