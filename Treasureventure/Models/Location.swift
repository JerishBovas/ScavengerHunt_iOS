//
//  Location.swift
//  Treasureventure
//
//  Created by Jerish Bovas on 2022-04-20.
//

import Foundation
import MapKit

struct Location : Identifiable, Equatable, Hashable {
    let name: String
    let description: String
    let address: String
    let coordinates: CLLocationCoordinate2D
    let item: String
    let image: String
    let difficulty: difficultyEnum
    let ratings: Int
    
    var id: String {
        name + item
    }
    
    //Equatable
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

enum difficultyEnum: String {
    case Easy
    case Medium
    case Hard
}
