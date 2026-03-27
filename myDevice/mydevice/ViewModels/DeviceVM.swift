//
//  DeviceVM.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 27/03/2026.
//

import Foundation
import Combine

final class DeviceVM: ObservableObject {
    @Published var idfa: String = ""
    @Published var attStatus: String = ""
    @Published var idfv: String = ""

    private let service: DeviceServiceProtocol

    init(service: DeviceServiceProtocol = DeviceServiceProvider()) {
        self.service = service
        refreshData()
    }

    func refreshData() {
        self.idfa = service.getIDFA()
        self.attStatus = service.getATTStatus()
        self.idfv = service.getIDFV()
    }
}
