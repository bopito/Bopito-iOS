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

}

