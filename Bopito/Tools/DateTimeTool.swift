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
    
    func convertSwiftDateToSupabaseString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX" // ISO 8601 format with timezone
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensuring UTC timezone
        return formatter.string(from: date)
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
        } else if hours < 24 {
            return "\(Int(hours))h"
        } else {
            return "\(Int(days))d"
        }
    }
    
}
