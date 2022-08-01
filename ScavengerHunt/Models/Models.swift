//
//  Models.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-06-24.
//

import Foundation
import MapKit

struct User: Codable, Hashable, Identifiable, Equatable{
    var id: String
    var name: String
    var email: String
    var profileImage: String
    var userLog: UserLog
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct UserLog: Codable{
    var userScore: Int
    var lastUpdated: String
}

struct Game : Identifiable, Equatable, Codable, Hashable {
    
    var id: String
    var isPrivate: Bool
    var name: String
    var description: String
    var address: String
    var country: String
    var coordinate: Coordinate
    var imageName: String
    var difficulty: Int
    var ratings: Double
    var tags: [String]
    var createdDate: String
    var lastUpdated: String
    
    //Equatable
    static func == (lhs: Game, rhs: Game) -> Bool {
        lhs.id == rhs.id
    }
    
    //Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Team: Codable, Equatable{
    var id: String
    var isOpen: Bool
    var title: String
    var description: String
    var teamIcon: String
    var members: Set<String>?
    var pastWinners: Set<ScoreLog>?
    
    //Equatable
    static func == (lhs: Team, rhs: Team) -> Bool {
        lhs.id == rhs.id
    }
}

struct ScoreLog: Hashable, Codable{
    var datePlayed: String
    var gameName: String
    var score: Int
    
    var id: String{
        return datePlayed + gameName
    }
}

enum Sort: String, CaseIterable, Identifiable {
    case relevance, mostPopular, mostPlayed, hard, easy
    var id: Self { self }
}

struct Coordinate: Codable{
    var latitude: Double
    var longitude: Double
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
struct AppError: Identifiable, Error{
    var id = UUID()
    var title: String
    var message: String
}

struct ErrorObject: Decodable, Error{
    var title: String
    var status: Int
    var errors: Set<String>
}

struct ImageRequest{
    var imageFile: Data
    var fileName: String
}

struct ImageResponse: Decodable{
    var imagePath: String
}

struct ImageObject: Decodable{
    var image: Data
}
