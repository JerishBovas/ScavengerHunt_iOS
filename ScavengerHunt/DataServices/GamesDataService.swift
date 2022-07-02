//
//  GamesDataService.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-20.
//

import Foundation

class GamesDataService {
    static let game: Game = Game(
        id: "s8499f-2949fh29-2e9fu9-249u",
        isPrivate: false,
        name: "Commerce Court",
        description: "Commerce Court in Toronto",
        address: "199 Bay St, Toronto, ON M5L 1L5",
        country: "Canada",
        coordinate: Coordinate(latitude: 43.6483965, longitude: -79.3794356),
        imageName: "https://scavengerhuntapi.blob.core.windows.net/images/ab82a5bb-c68f-40f9-b2f6-42ea13f0eb1d-8585449087925704678.jpeg",
        difficulty: 3,
        ratings: 5,
        tags: ["comer", "codmn"],
        createdDate: Date.now.description,
        lastUpdated: Date.now.description
    )
    
    static let group: Group = Group(
        id: "234jo2ro", isOpen: true, title: "Sample", description: "Sample Description", groupIcon: "https://scavengerhuntapi.blob.core.windows.net/images/ab82a5bb-c68f-40f9-b2f6-42ea13f0eb1d-8585449087925704678.jpeg"
    )
    
}
