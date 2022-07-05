//
//  Team.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-07-02.
//

import Foundation

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
