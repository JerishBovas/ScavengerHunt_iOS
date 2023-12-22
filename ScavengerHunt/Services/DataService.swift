//
//  GamesDataService.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-20.
//

import Foundation

class DataService {
    
    static let game: Game = Game(
        id: "s8499f-2949fh29-2e9fu9-249u",
        isPrivate: false,
        name: "Commerce Court",
        description: "Commerce Court in Toronto",
        address: "199 Bay St, Toronto, ON M5L 1L5",
        country: "Canada",
        userId: "s8499f-2949fh29-2e9fu9-249u",
        isUser: false,
        coordinate: Coordinate(latitude: 43.6483965, longitude: -79.3794356),
        imageName: "https://scavengerhuntapi.blob.core.windows.net/images/ab82a5bb-c68f-40f9-b2f6-42ea13f0eb1d-8585449087925704678.jpeg",
        difficulty: 3,
        ratings: 3,
        tags: ["comer", "codmn"],
        gameDuration: 0,
        createdDate: Date.now.description,
        lastUpdated: Date.now.description
    )
    
    static let user: User = User(id: UUID().uuidString, name: "Jerish Bovas", email: "jerishbovas@gmail.com", profileImage: "https://scavengerhuntapi.blob.core.windows.net/images/ab82a5bb-c68f-40f9-b2f6-42ea13f0eb1d-8585449087925704678.jpeg", score: 1000, games: 0, teams: 0, lastUpdated: Date.now.description)
    
    static let team: Team = Team(
        id: "234jo2ro", adminId: "", isOpen: true, title: "Sample", description: "Sample Description", members: 4, teamIcon: "https://scavengerhuntapi.blob.core.windows.net/images/ab82a5bb-c68f-40f9-b2f6-42ea13f0eb1d-8585449087925704678.jpeg"
    )
    
    static func getUser() -> User{
        var user = user
        user.id = UUID().uuidString
        return user
    }
    
    static func getGame()->Game{
        var game = game
        game.id = UUID().uuidString
        return game
    }
}
