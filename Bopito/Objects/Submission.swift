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
    
    init(id: String,
         author_id: String,
         parent_id: String?,
         image: String?,    // Optional, defaults to nil if no image
         text: String,
         created_at: String?,
         edited_at: String?
    ) {
        self.id = id
        self.author_id = author_id
        self.parent_id = parent_id
        self.image = image
        self.text = text
        self.created_at = created_at
        self.edited_at = edited_at
    }
}
