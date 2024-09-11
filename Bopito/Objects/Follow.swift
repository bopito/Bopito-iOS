//
//  Follow.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/11/24.
//

import Foundation
import SwiftUI


class Follow: Identifiable, Codable {
    var id: String
    var user_id: String
    var follower_id: String
    
    init(id: String,
         user_id: String,
         follower_id: String
    ) {
        self.id = id
        self.user_id = user_id
        self.follower_id = follower_id
    }
}
