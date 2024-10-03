//
//  Block.swift
//  Bopito
//
//  Created by Hans Heidmann on 10/3/24.
//

import Foundation
import SwiftUI

struct Block: Identifiable, Codable {
    var id: String
    var created_at: String?
    var blocker_id: String
    var blocked_id: String
}
