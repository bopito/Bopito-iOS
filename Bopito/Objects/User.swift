import Foundation
import SwiftUI


class User: Identifiable, Codable {
    var id: String
    var email: String?
    var phone: String?
    var username: String
    var bio: String?
    var profile_picture: String
    var name: String?
    var followers_count: Int
    var following_count: Int
    
    init(id: String,
         email: String?,
         phone: String?,
         username: String,
         bio: String?,
         profile_picture: String,
         name: String?,
         followers_count: Int,
         following_count: Int
    ) {
        self.id = id
        self.email = email
        self.phone = phone
        self.username = username
        self.bio = bio
        self.profile_picture = profile_picture
        self.name = name
        self.followers_count = followers_count
        self.following_count = following_count
    }
}

