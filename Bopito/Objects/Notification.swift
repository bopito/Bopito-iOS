//
//  Notification.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/13/24.
//

import Foundation
import SwiftUI


struct Notification: Identifiable, Codable {
    var id: String
    var recipient_id: String
    var sender_id: String
    var type: String // like, comment, follow, new post
    var submission_id: String?
    var created_at: String?
    var is_read: Bool
    var message: String
}
