//
//  ScavengerHuntApp.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-19.
//

import SwiftUI

@main
struct ScavengerHuntApp: App {
    @StateObject private var gameVM = GameViewModel()
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var teamVM = TeamViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavBarView()
                .environmentObject(gameVM)
                .environmentObject(authVM)
                .environmentObject(teamVM)
        }
    }
}
