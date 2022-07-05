//
//  GameViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-20.
//

import Foundation
import MapKit
import SwiftUI

class TeamViewModel: ObservableObject {
    
    @Published var teams = [Team]()
    @State var authVM = AuthViewModel()
    private var api: ApiService = ApiService()
    
    func getTeams() async{
        do{
            let defaults = UserDefaults.standard
            if(await !authVM.refreshToken()){
                return
            }
            
            guard let accessToken = defaults.string(forKey: "accessToken") else {
                return
            }
            
            let teams: [Team] = try await api.get(accessToken: accessToken, endpoint: .team)
            print("Games fetched")
            DispatchQueue.main.async {
                self.teams = teams
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
