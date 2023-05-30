//
//  Team.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-03.
//

import Foundation

struct Team: Identifiable, Equatable, Codable, Hashable{
    var id: String
    var adminId: String
    var isOpen: Bool
    var title: String
    var description: String
    var members: Int
    var teamIcon: String
    
    init(id: String, adminId: String, isOpen: Bool, title: String, description: String, members: Int, teamIcon: String) {
        self.id = id
        self.adminId = adminId
        self.isOpen = isOpen
        self.title = title
        self.description = description
        self.members = members
        self.teamIcon = teamIcon
    }
}
