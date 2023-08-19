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
    private var api: ApiService = ApiService()
    
    func getTeams() async throws{
        
    }
}
