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
    @State var authVM = AuthViewModel()
    private var api: ApiService = ApiService()
    
    func getTeams() async throws{
        let defaults = UserDefaults.standard
        try await authVM.refreshToken()
        
        guard let accessToken = defaults.string(forKey: "accessToken") else {
            return
        }
        
        let teams: [Team] = try await api.get(accessToken: accessToken, endpoint: APIEndpoint.team.description)
        print("Games fetched")
        DispatchQueue.main.async {
            self.teams = teams
        }
    }
}
