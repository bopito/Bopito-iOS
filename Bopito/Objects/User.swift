import Foundation
import SwiftUI


class User: Identifiable, Codable {
    var id: String
    var username: String
    var bio: String?
    var profile_picture: String
    var name: String
    var followers_count: Int
    var following_count: Int
    var verified: Bool
    var balance: Int
    var fcm_token: String?
    var created_at: String?
    var last_login: String?
    var last_action_datetime: String?
//
//    init(id: String,
//         username: String,
//         bio: String?,
//         profile_picture: String,
//         name: String,
//         followers_count: Int,
//         following_count: Int,
//         verified: Bool,
//         balance: Int,
//         fcm_token: String?
//    ) {
//        self.id = id
//        self.username = username
//        self.bio = bio
//        self.profile_picture = profile_picture
//        self.name = name
//        self.followers_count = followers_count
//        self.following_count = following_count
//        self.verified = verified
//        self.balance = balance
//        self.fcm_token = fcm_token
//    }
}

