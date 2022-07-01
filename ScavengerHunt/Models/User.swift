//
//  User.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-06-21.
//

import Foundation

struct User: Decodable{
    var id: String
    var name: String
    var email: String
    var profileImage: String
    var userLog: UserLog
}
