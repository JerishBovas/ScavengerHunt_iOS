//
//  Group.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-07-02.
//

import Foundation

struct Group: Codable, Equatable{
    var id: String
    var isOpen: Bool
    var title: String
    var description: String
    var groupIcon: String
    var members: Set<String>?
    var pastWinners: Set<ScoreLog>?
    
    //Equatable
    static func == (lhs: Group, rhs: Group) -> Bool {
        lhs.id == rhs.id
    }
}
