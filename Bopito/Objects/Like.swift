//
//  Like.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/6/24.
//

import Foundation
import SwiftUI


class Like: Identifiable, Codable {
    var id: String
    var submission_id: String
    var user_id: String
    
    init(id: String,
         submission_id: String,
         user_id: String
    ) {
        self.id = id
        self.submission_id = submission_id
        self.user_id = user_id
    }
}


