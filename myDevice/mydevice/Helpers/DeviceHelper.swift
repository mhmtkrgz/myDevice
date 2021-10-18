//
//  DeviceHelper.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 18.10.2021.
//

import UIKit
import AdSupport
import AppTrackingTransparency
import CoreTelephony

struct DeviceHelper {
    
    struct Device {
        static var osVersion: String {
            return UIDevice.current.systemVersion
        }
        
        static var deviceModel: String {
            return UIDevice.modelName
        }
        
        static func carrierName() -> String? {
            let networkInfo = CTTelephonyNetworkInfo()
            let provider = networkInfo.serviceSubscriberCellularProviders
            guard let carrier = provider?.first?.value else { return nil }
            return carrier.carrierName
        }
        
        static func connectionType() -> String? {
            let networkInfo = CTTelephonyNetworkInfo()
            guard let type = networkInfo.serviceCurrentRadioAccessTechnology?.values.first else { return nil }
            
            switch type {
            case "CTRadioAccessTechnologyGPRS",
                "CTRadioAccessTechnologyEdge",
                "CTRadioAccessTechnologyCDMA1x":
                return "2g"
            case "CTRadioAccessTechnologyWCDMA",
                "CTRadioAccessTechnologyHSDPA",
                "CTRadioAccessTechnologyHSUPA",
                "CTRadioAccessTechnologyCDMAEVDORev0",
                "CTRadioAccessTechnologyCDMAEVDORevA",
                "CTRadioAccessTechnologyCDMAEVDORevB",
                "CTRadioAccessTechnologyeHRPD":
                return "3g"
            case "CTRadioAccessTechnologyLTE":
                return "4g"
            default:
                return nil
            }
        }
        
        static var country: String {
            return (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? ""
        }
        
        static var language: String {
            return Locale.current.languageCode ?? ""
        }
        
        static var timezone: String {
            return TimeZone.current.abbreviation() ?? ""
        }
    }
    
    static var IDFA: String {
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    static var IDFV: String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    static var isATTSupported: Bool {
        if #available(iOS 14.0, *) {
            return true
        }
        
        return false
    }
    
    static var ATTStatusString: String {
        if #available(iOS 14, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .authorized:
                return "Authorized"
            case .denied:
                return "Denied"
            case .notDetermined:
                return "Not Determined"
            case .restricted:
                return "Restricted"
            default:
                return ""
            }
        }
        
        return ""
    }
    
    static var isATTAccepted: Bool {
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus == .authorized {
                return true
            }
        }
        
        return false
    }
}
