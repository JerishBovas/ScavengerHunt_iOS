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
    @StateObject private var authVM = HomeViewModel()
    @StateObject private var teamVM = TeamViewModel()
    @StateObject private var loginVM = LoginViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameVM)
                .environmentObject(authVM)
                .environmentObject(teamVM)
                .environmentObject(loginVM)
        }
    }
}
