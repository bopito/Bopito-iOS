//
//  RandomGeneratorTool.swift
//  Bopito
//
//  Created by Hans Heidmann on 9/10/24.
//

import Foundation

class RandomGeneratorTool {
    
    static let shared = RandomGeneratorTool() // Singleton instance
        
    private init() {} // Private init prevents direct instantiation
    
    func randomAlphaNumericString(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""
        
        for _ in 0 ..< length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
}
