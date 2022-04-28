//
//  TreasureventureApp.swift
//  Treasureventure
//
//  Created by Jerish Bovas on 2022-04-19.
//

import SwiftUI

@main
struct TreasureventureApp: App {
    @StateObject private var vm = LocationsViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(vm)
        }
    }
}
