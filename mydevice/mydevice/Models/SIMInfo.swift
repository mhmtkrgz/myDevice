//
//  SIMInfo.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 27/03/2026.
//

import Foundation

struct SIMInfo: Identifiable {
    let id = UUID()
    let index: Int
    let isESIM: Bool
    let radioTech: String // "LTE", "5G", "3G", etc. Empty if radio is idle.

    var label: String { "Carrier \(index)" }
    var value: String {
        let type = isESIM ? "E-SIM" : "SIM"
        return radioTech.isEmpty ? type : "\(type) (\(radioTech))"
    }

    var icon: String { isESIM ? "esim" : "simcard" }
}
