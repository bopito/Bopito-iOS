//
//  Boost.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/25/24.
//

import Foundation
import SwiftUI

struct Boost: Identifiable, Codable {
    var id: String
    var created_at: String?
    var expires_at: String
    var value: Int 
    var submission_id: String
    var user_id: String
    var live: Bool
    var price: Int
    var time: Int
    var category: String
}
