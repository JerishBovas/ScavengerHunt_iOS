//
//  APIEndpoint.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-07-01.
//

import Foundation

enum APIEndpoint : CustomStringConvertible{
    case register, login, refreshToken, revokeToken, resetPassword
    case users, user, userProfileImage, userNameUpdate
    case homeLeaderboard, homePopularGames
    case game, gameCreate, gameId(id: String, userId: String), gameItemId(id: String, itemId: String), uploadGameImage
    case team, teamId(id: String), uploadTeamImage
    case item(gameId: String)
    
    private var DOMAIN_URL: String {
        let url = Bundle.main.infoDictionary?["API_ENDPOINT"] as! String
        return "https://\(url)"
    }
    
    var description: String{
        switch self{
            
        case .register: return "\(DOMAIN_URL)/v1/auth/register"
        case .login: return "\(DOMAIN_URL)/v1/auth/login"
        case .refreshToken: return "\(DOMAIN_URL)/v1/auth/refreshtoken"
        case .revokeToken : return "\(DOMAIN_URL)/v1/auth/revoketoken"
        case .resetPassword : return "\(DOMAIN_URL)/v1/auth/resetpassword"
            
        case .users : return "\(DOMAIN_URL)/v1/users/all"
        case .user : return "\(DOMAIN_URL)/v1/users"
        case .userProfileImage : return "\(DOMAIN_URL)/v1/users/profileimage"
        case .userNameUpdate : return "\(DOMAIN_URL)/v1/users/name"
            
        case .homeLeaderboard : return "\(DOMAIN_URL)/v1/home/leaderboard"
        case .homePopularGames : return "\(DOMAIN_URL)/v1/home/populargames"
            
        case .game : return "\(DOMAIN_URL)/v1/games"
        case .gameCreate : return "\(DOMAIN_URL)/v1/games"
        case .gameId(let id, let userId) : return "\(DOMAIN_URL)/v1/games/\(id)/?userid=\(userId)"
        case .gameItemId(let id, let itemId) : return "\(DOMAIN_URL)/v1/games/\(id)/\(itemId)"
        case .uploadGameImage : return "\(DOMAIN_URL)/v1/games/image"
            
        case .item(let gameId) : return "\(DOMAIN_URL)/v1/games/\(gameId)/items"
        
        case .team : return "\(DOMAIN_URL)/v1/team/"
        case .teamId(let id) : return "\(DOMAIN_URL)/v1/team/\(id)"
        case .uploadTeamImage : return "\(DOMAIN_URL)/v1/team/image"
        }
    }
}
