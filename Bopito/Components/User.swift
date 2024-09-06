import Foundation
import SwiftUI


class User: Identifiable, Codable {
    var id: String
    var email: String?
    var phone: String?
    var username: String
    var bio: String
    var profile_picture: String
    
    init(id: String,
         email: String?,
         phone: String?,
         username: String,
         bio: String,
         profile_picture: String
    ) {
        self.id = id
        self.email = email
        self.phone = phone
        self.username = username
        self.bio = bio
        self.profile_picture = profile_picture
    }
}

