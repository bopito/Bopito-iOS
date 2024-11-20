//
//  PII.swift
//  Bopito
//
//  Created by Hans Heidmann on 11/20/24.
//

import Foundation


class PII: Identifiable, Codable {
    var id: String
    var user_id: String
    var balance: Int
    var fcm_token: String?
    var last_action: String?

}

