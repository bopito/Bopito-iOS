//
//  DateTimeTool.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/10/24.
//

import Foundation

class DateTimeTool {
    
    static let shared = DateTimeTool() // Singleton instance
        
    private init() {} // Private init prevents direct instantiation
    
    func getSwiftDate(supabaseTimestamp: String) -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Support for fractional seconds
        return isoFormatter.date(from: supabaseTimestamp+"Z")
    }
    
    func timeAgo(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        let minutes = timeInterval / 60
        let hours = minutes / 60
        let days = hours / 24
        let months = days / 30
        let years = months / 12
        
        if minutes < 60 {
            return "\(Int(minutes))m"
        } else if hours < 25 {
            return "\(Int(hours))h"
        } else {
            return "\(Int(days))d"
        }
    }
    
}
