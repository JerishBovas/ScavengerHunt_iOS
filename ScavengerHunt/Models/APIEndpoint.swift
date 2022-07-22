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
    
    private var DOMAIN_URL: String {
        return "https://scavengerhuntapi.azurewebsites.net"
    }
    
    var description: String{
        switch self{
            
        case .register: return "\(DOMAIN_URL)/api/auth/register"
        case .login: return "\(DOMAIN_URL)/api/auth/login"
        case .refreshToken: return "\(DOMAIN_URL)/api/auth/refreshtoken"
        case .revokeToken : return "\(DOMAIN_URL)/api/auth/revoketoken"
        case .resetPassword : return "\(DOMAIN_URL)/api/auth/resetpassword"
        case .changeName : return "\(DOMAIN_URL)/api/auth/changename"
        case .uploadProfile : return "\(DOMAIN_URL)/api/auth/addimage"
            
        case .home : return "\(DOMAIN_URL)/api/home"
        case .homeScores : return "\(DOMAIN_URL)/api/home/scores"
        case .uploadImage : return "\(DOMAIN_URL)/api/home/uploadimage"
            
        case .game : return "\(DOMAIN_URL)/api/game/"
        case .gameId(let id) : return "\(DOMAIN_URL)/api/game/\(id)"
        case .gameItemId(let id, let itemId) : return "\(DOMAIN_URL)/api/game/\(id)/\(itemId)"
        
        case .team : return "\(DOMAIN_URL)/api/team/"
        case .teamId(let id) : return "\(DOMAIN_URL)/api/team/\(id)"
        }
    }
}
