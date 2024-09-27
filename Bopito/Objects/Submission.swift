//
//  Submission.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/5/24.
//

import SwiftUI
import Foundation

class Submission: Identifiable, Codable {
    var id: String
    var author_id: String    // Foreign key reference to the user
    var parent_id: String?      // Foreign key for parent submission
    var image: String?
    var text: String
    var created_at: String?
    var edited_at: String?
    var likes_count: Int
    var dislikes_count: Int
    var boosts_count: Int
    var replies_count: Int
    var score: Int
    var reports: Int
    
    init(id: String,
         author_id: String,
         parent_id: String?,
         image: String?,    // Optional, defaults to nil if no image
         text: String,
         created_at: String?,
         edited_at: String?,
         likes_count: Int,
         dislikes_count: Int,
         boosts_count: Int,
         replies_count: Int,
         score: Int,
         reports: Int
    ) {
        self.id = id
        self.author_id = author_id
        self.parent_id = parent_id
        self.image = image
        self.text = text
        self.created_at = created_at
        self.edited_at = edited_at
        self.likes_count = likes_count
        self.dislikes_count = dislikes_count
        self.boosts_count = boosts_count
        self.replies_count = replies_count
        self.score = score
        self.reports = reports
    }
}
