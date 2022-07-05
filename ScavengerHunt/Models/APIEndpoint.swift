//
//  APIEndpoint.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-07-01.
//

import Foundation

enum APIEndpoint : CustomStringConvertible{
    case register, login, refreshToken, revokeToken, resetPassword, changeName, uploadProfile
    case home, homeScores, uploadImage
    case game, gameId(id: String), gameItemId(id: String, itemId: String)
    case team, teamId(id: String)
    
    var description: String{
        switch self{
            
        case .register: return "https://scavengerhuntapis.azurewebsites.net/api/auth/register"
        case .login: return "https://scavengerhuntapis.azurewebsites.net/api/auth/login"
        case .refreshToken: return "https://scavengerhuntapis.azurewebsites.net/api/auth/refreshtoken"
        case .revokeToken : return "https://scavengerhuntapis.azurewebsites.net/api/auth/revoketoken"
        case .resetPassword : return "https://scavengerhuntapis.azurewebsites.net/api/auth/resetpassword"
        case .changeName : return "https://scavengerhuntapis.azurewebsites.net/api/auth/changename"
        case .uploadProfile : return "https://scavengerhuntapis.azurewebsites.net/api/auth/addimage"
            
        case .home : return "https://scavengerhuntapis.azurewebsites.net/api/home"
        case .homeScores : return "https://scavengerhuntapis.azurewebsites.net/api/home/scores"
        case .uploadImage : return "https://scavengerhuntapis.azurewebsites.net/api/home/uploadimage"
            
        case .game : return "https://scavengerhuntapis.azurewebsites.net/api/game/"
        case .gameId(let id) : return "https://scavengerhuntapis.azurewebsites.net/api/game/\(id)"
        case .gameItemId(let id, let itemId) : return "https://scavengerhuntapis.azurewebsites.net/api/game/\(id)/\(itemId)"
        
        case .team : return "https://scavengerhuntapis.azurewebsites.net/api/team/"
        case .teamId(let id) : return "https://scavengerhuntapis.azurewebsites.net/api/team/\(id)"
        }
    }
}
