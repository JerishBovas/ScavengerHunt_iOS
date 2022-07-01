//
//  ScavengerHuntApp.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-19.
//

import SwiftUI

@main
struct ScavengerHuntApp: App {
    @StateObject private var locVM = GameViewModel()
    @StateObject private var authVM = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavBarView()
                .environmentObject(locVM)
                .environmentObject(authVM)
        }
    }
}
