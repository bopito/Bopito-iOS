//
//  BoostInfo.swift
//  Bopito
//
//  Created by Hans Heidmann on 10/17/24.
//

import SwiftUI

struct BoostInfo: Identifiable, Codable {
    var id: String
    var name: String
    var power: Int
    var price: Int
    var time: Int
}
