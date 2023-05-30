//
//  Game.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-03.
//

import Foundation

struct GameDetail: Identifiable, Equatable, Codable, Hashable{
    var id: String = ""
    var isPrivate: Bool = false
    var isReadyToPlay: Bool=false
    var name: String = ""
    var description: String = ""
    var address: String = ""
    var country: String = ""
    var userId: String = ""
    var isUser: Bool = false
    var coordinate: Coordinate = Coordinate()
    var items: [Item] = []
    var imageName: String = ""
    var difficulty: Int = 0
    var ratings: Double = 0
    var tags: [String] = []
    var gameDuration: Int = 0
    var createdDate: String = Date.now.description
    var lastUpdated: String = Date.now.description
}

struct Game: Identifiable, Equatable, Codable, Hashable{
    var id: String = ""
    var name: String = ""
    var address: String = ""
    var country: String = ""
    var userId: String = ""
    var imageName: String = ""
}

struct Coordinate: Equatable, Codable, Hashable{
    var latitude: Double = 0
    var longitude: Double = 0
}

struct Item: Equatable, Codable, Hashable{
    var id: String = ""
    var name: String = ""
    var imageUrl: String = ""
    
    init(name: String) {
        self.id = ""
        self.name = name
        self.imageUrl = ""
    }
}

struct NewGame: Codable, Hashable{
    var isPrivate: Bool = false
    var name: String = ""
    var description: String = ""
    var address: String = ""
    var country: String = ""
    var coordinate: Coordinate?
    var imageName: String = ""
    var difficulty: Int = 0
    var tags: [String] = [String]()
}

struct GameCreateResp: Codable{
    var id: String
}
