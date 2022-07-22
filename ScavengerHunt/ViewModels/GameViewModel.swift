//
//  GameViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-20.
//

import Foundation
import CoreLocation
import SwiftUI
import WeatherKit

class GameViewModel: ObservableObject {
    
    @Published var games = [Game]()
    @State var authVM = LoginViewModel()
    private var api: ApiService = ApiService()
    @State var temperature: Double? = nil
    @State var uvIndex: Int? = nil
    @Published  var appError: AppError? = nil
    
    func getGames() async{
        do{
            let defaults = UserDefaults.standard
            try await authVM.refreshToken()
            
            guard let accessToken = defaults.string(forKey: "accessToken") else {
                return
            }
            
            let games: [Game] = try await api.get(accessToken: accessToken, endpoint: .game)
            print("Games fetched")
            DispatchQueue.main.async {
                self.games = games
            }
        }
        catch ErrorType.error(let error){
            DispatchQueue.main.async {
                self.appError = error.appError
            }
        }
        catch{
            DispatchQueue.main.async {
                self.appError = AppError(title: "Something went wrong", message: error.localizedDescription)
            }
            print("Request failed with error: \(error.localizedDescription)")
        }
    }
}
