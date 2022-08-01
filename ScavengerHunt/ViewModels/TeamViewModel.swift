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
    @Published var appError: AppError? = nil
    @State var authVM = LoginViewModel()
    private var api: ApiService = ApiService()
    
    func getTeams() async{
        do{
            let defaults = UserDefaults.standard
            try await authVM.refreshToken()
            
            guard let accessToken = defaults.string(forKey: "accessToken") else {
                return
            }
            
            let teams: [Team] = try await api.get(accessToken: accessToken, endpoint: .team)
            print("Games fetched")
            DispatchQueue.main.async {
                self.teams = teams
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
