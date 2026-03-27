//
//  HardwareService.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 27/03/2026.
//

import UIKit
import Foundation

protocol HardwareServiceProtocol {
    func storageTuple() -> (used: Int64, total: Int64)?
    func displayResolution() -> String
}

final class HardwareService: HardwareServiceProtocol {
    func storageTuple() -> (used: Int64, total: Int64)? {
        let url = URL(fileURLWithPath: NSHomeDirectory())
        guard let values = try? url.resourceValues(forKeys: [
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey
        ]),
        let total = values.volumeTotalCapacity,
        let available = values.volumeAvailableCapacityForImportantUsage else { return nil }

        let totalBytes = Int64(total)
        let usedBytes = totalBytes - available
        return (usedBytes, totalBytes)
    }

    func displayResolution() -> String {
        let bounds = UIScreen.main.nativeBounds
        return "\(Int(bounds.width)) × \(Int(bounds.height))"
    }
}
