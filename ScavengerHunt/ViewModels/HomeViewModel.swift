//
//  HomeViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-07-17.
//

import Foundation

class HomeViewModel: ObservableObject{
    @Published var user: User? = nil
    @Published var scoreLog: ScoreLog? = nil
    @Published var leaderBoard: Set<User>? = nil
    @Published var gotd: Game? = nil
    @Published var favorites: Set<Game>? = nil
    @Published var myGames: Set<Game>? = nil
    
    
}
