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
    var liker_id: String
    var receiver_id: String
    var value: Int
    
    init(id: String,
         submission_id: String,
         liker_id: String,
         receiver_id: String,
         value: Int
    ) {
        self.id = id
        self.submission_id = submission_id
        self.liker_id = liker_id
        self.receiver_id = receiver_id
        self.value = value
    }
}


