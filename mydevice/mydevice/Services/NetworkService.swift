//
//  NetworkService.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 27/03/2026.
//

import Network
import Foundation
import Combine
import Darwin

protocol NetworkServiceProtocol {
    func connectionType() -> String
    func localIP() -> String
    var pathPublisher: AnyPublisher<Void, Never> { get }
}

final class NetworkService: NetworkServiceProtocol {
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.mydevice.NetworkMonitor", qos: .background)
    private let pathSubject = PassthroughSubject<Void, Never>()
    private var currentPath: NWPath?

    var pathPublisher: AnyPublisher<Void, Never> { pathSubject.eraseToAnyPublisher() }

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.currentPath = path
                self?.pathSubject.send()
            }
        }
        monitor.start(queue: monitorQueue)
    }

    deinit {
        monitor.cancel()
    }

    func connectionType() -> String {
        guard let path = currentPath else { return "Unknown" }
        if path.usesInterfaceType(.wifi)          { return "Wi-Fi" }
        if path.usesInterfaceType(.cellular)      { return "Cellular" }
        if path.usesInterfaceType(.wiredEthernet) { return "Ethernet" }
        return path.status == .satisfied ? "Connected" : "No Connection"
    }

    func localIP() -> String {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return "Unknown" }
        defer { freeifaddrs(ifaddr) }

        var ptr = ifaddr
        while let interface = ptr {
            let flags = Int32(interface.pointee.ifa_flags)
            let addr = interface.pointee.ifa_addr.pointee
            if (flags & (IFF_UP | IFF_RUNNING | IFF_LOOPBACK)) == (IFF_UP | IFF_RUNNING),
               addr.sa_family == UInt8(AF_INET) {
                let name = String(cString: interface.pointee.ifa_name)
                if name == "en0" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    let addrCopy = interface.pointee.ifa_addr
                    if getnameinfo(addrCopy, socklen_t(addr.sa_len),
                                   &hostname, socklen_t(hostname.count),
                                   nil, 0, NI_NUMERICHOST) == 0 {
                        address = String(cString: hostname)
                    }
                }
            }
            ptr = interface.pointee.ifa_next
        }
        return address ?? "Not Connected"
    }
}
