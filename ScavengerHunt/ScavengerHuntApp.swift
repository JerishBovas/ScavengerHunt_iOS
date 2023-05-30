//
//  ScavengerHuntApp.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-03-29.
//

import SwiftUI

@main
struct ScavengerHuntApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var router = Router()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .environmentObject(router)
        }
    }
}
