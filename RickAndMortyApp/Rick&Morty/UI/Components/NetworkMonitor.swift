//
//  NetworkMonitor.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 29/4/25.
//


import Network
import Foundation
import Observation

@Observable
final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private(set) var isConnected: Bool = true
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            
            let isConnected = !path.availableInterfaces.isEmpty && path.status == .satisfied
            
            DispatchQueue.main.async {
                self.isConnected = isConnected
                print("Conectado: \(isConnected)")
            }
        }
        monitor.start(queue: queue)
    }
}
