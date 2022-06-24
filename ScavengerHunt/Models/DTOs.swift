//
//  DTOs.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-06-24.
//

import Foundation

struct LoginRequest: Encodable{
    var email: String
    var password: String
}

struct TokenObject: Decodable, Encodable{
    var accessToken: String
    var refreshToken: String
}

struct ErrorObject: Decodable, Error{
    var title: String
    var status: Int
    var errors: Set<String>
}
