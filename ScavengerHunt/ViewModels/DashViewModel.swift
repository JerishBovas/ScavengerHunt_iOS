//
//  DashViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-07-17.
//

import Foundation
import UIKit
import SwiftUI

class DashViewModel: ObservableObject{
    private var accessToken: String?
    private var api: ApiService
    
    @Published var user: User?
    @Published var gotd: Game?
    @Published var leaderBoard: [User]?
    @Published var popularGames: [Game]?
    
    init(){
        self.accessToken = UserDefaults.standard.string(forKey: "accessToken")
        api = ApiService()
        if let data = UserDefaults.standard.data(forKey: "user"),
           let use = try? JSONDecoder().decode(User.self, from: data){
            withAnimation {
                self.user = use
            }
        }
    }
    
    func fetchPage() async{
        async let fetchedLeaderboard: [User]? = try? await api.get(endpoint: APIEndpoint.homeLeaderboard.description)
        async let fetchedPopularGames: [Game]? = try? await api.get(endpoint: APIEndpoint.homePopularGames.description)

        let leaderBoard = await fetchedLeaderboard
        let popularGames = await fetchedPopularGames

        DispatchQueue.main.async {
            if let leaderBoard = leaderBoard {
                withAnimation(.default) {
                    self.leaderBoard = leaderBoard
                }
            }
            
            if let popularGames = popularGames {
                withAnimation(.default) {
                    self.popularGames = popularGames
                    if !popularGames.isEmpty{
                        self.gotd = popularGames[0]
                    }
                }
            }
            print("Page Fetched")
        }
        if let accessToken = accessToken{
            async let fetchedUser: User? = try? await api.get(accessToken: accessToken, endpoint: APIEndpoint.user.description)
            let user = await fetchedUser
            DispatchQueue.main.async {
                if let user = user {
                    withAnimation(.default) {
                        self.user = user
                    }
                    if let encoded = try? JSONEncoder().encode(user) {
                        UserDefaults.standard.set(encoded, forKey: "user")
                    }
                }
            }
        }
    }
}
