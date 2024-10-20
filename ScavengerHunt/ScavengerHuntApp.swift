//
//  ScavengerHuntApp.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-03-29.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth

@main
struct ScavengerHuntApp: App {
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AuthenticatedView()
        }
    }
}
