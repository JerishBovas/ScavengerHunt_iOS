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
    
    @Published var gotd: Game?
    @Published var leaderBoard: [User]?
    @Published var popularGames: [Game]?
    
    init(){
        self.accessToken = UserDefaults.standard.string(forKey: "accessToken")
        api = ApiService()
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
    }
}
