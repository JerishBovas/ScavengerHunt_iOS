//
//  User.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-03.
//

import Foundation

struct User: Codable, Hashable, Identifiable, Equatable{
    var id: String
    var name: String
    var email: String
    var profileImage: String
    var score: Int
    var games: Int
    var teams: Int
    var lastUpdated: String
    
    init(){
        self.id = UUID().uuidString
        self.name = ""
        self.email = ""
        self.profileImage = ""
        self.score = 0
        self.games = 0
        self.teams = 0
        self.lastUpdated = Date.now.description
    }
    
    init(id: String, name: String, email: String, profileImage: String, score: Int, games: Int, teams: Int, lastUpdated: String) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImage = profileImage
        self.score = score
        self.games = games
        self.teams = teams
        self.lastUpdated = lastUpdated
    }
}

struct LoginRequest: Encodable{
    var email: String
    var password: String
}

struct SignUpRequest: Encodable{
    var name: String
    var email: String
    var password: String
}

struct TokenObject: Codable{
    var accessToken: String
    var refreshToken: String
}
