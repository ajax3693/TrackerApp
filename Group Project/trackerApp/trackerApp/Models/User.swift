//
//  User.swift
//  trackerApp
//
//  Created by AJ Cardoza on 11/6/23.
//

import Foundation
import ParseSwift

struct User: ParseUser {
    var objectId: String?
    var originalData: Data?
    var emailVerified: Bool?
    var ACL: ParseACL?
    var updatedAt: Date?
    var authData: [String: [String: String]?]?

    var username: String?
    var createdAt: Date?
    var password: String?
    var email: String?

    var score: Int?
    var userScore: String?
    var updatedScore: Int?

    var userImage: ParseFile?

    mutating func updateScore(withPoints itemPoints: Int) {
        let currentScore = Int(userScore ?? "") ?? 0
        let newScore = currentScore + itemPoints
        updatedScore = newScore
        userScore = String(newScore)
    }

}



