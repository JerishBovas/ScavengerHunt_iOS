//
//  GameViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-20.
//

import Foundation
import MapKit
import SwiftUI

class GameViewModel: ObservableObject {
    
    @Published var games = [Game]()
    @State var authVM = AuthViewModel()
    private var api: ApiService = ApiService()
    
    func getGames() async{
        do{
            let defaults = UserDefaults.standard
            if(await !authVM.refreshToken()){
                return
            }
            
            guard let accessToken = defaults.string(forKey: "accessToken") else {
                return
            }
            
            let games: [Game] = try await api.get(accessToken: accessToken, endpoint: .game)
            print("Games fetched")
            DispatchQueue.main.async {
                self.games = games
            }
        }
        catch NetworkError.custom(let error){
            print("Request failed with error: \(error)")
        }
        catch{
            print("Request failed with error: \(error.localizedDescription)")
        }
    }
}
