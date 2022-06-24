//
//  Location.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-20.
//

import Foundation
import MapKit

struct Location : Identifiable, Equatable, Codable {
    
    var id: String
    var isPrivate: Bool
    var name: String
    var description: String
    var address: String
    var country: String
    var coordinate: Coordinate
    var imageName: String
    var difficulty: Int
    var ratings: Set<Int>
    var tags: Set<String>
    var createdDate: String
    var lastUpdated: String
    
    //Equatable
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}
