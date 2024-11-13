//
//  NetworkMonitor.swift
//  Bopito
//
//  Created by Hans Heidmann on 11/12/24.
//

import SwiftUI
import Network

class NetworkMonitor: ObservableObject {
    private var monitor: NWPathMonitor
    private var queue = DispatchQueue(label: "NetworkMonitor")
    
    // Published property to track network availability
    @Published var isConnected: Bool = true
    
    init() {
        self.monitor = NWPathMonitor()
        
        // Start monitoring on the background queue
        self.monitor.start(queue: queue)
        
        // Listen for network changes
        self.monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                // Update isConnected based on network path status
                self?.isConnected = path.status == .satisfied
            }
        }
    }
    
    deinit {
        monitor.cancel()
    }
}
