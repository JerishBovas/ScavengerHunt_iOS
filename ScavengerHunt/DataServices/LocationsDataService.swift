//
//  LocationsDataService.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-20.
//

import Foundation

class LocationsDataService {
    static let location: Location = Location(
        id: "s8499f-2949fh29-2e9fu9-249u",
        isPrivate: false,
        name: "Commerce Court",
        description: "Commerce Court in Toronto",
        address: "199 Bay St, Toronto, ON M5L 1L5",
        country: "Canada",
        coordinate: Coordinate(latitude: 43.6483965, longitude: -79.3794356),
        imageName: "goldenkey",
        difficulty: 3,
        ratings: [5],
        tags: ["comer", "codmn"],
        createdDate: Date.now.description,
        lastUpdated: Date.now.description
    )
    
}
