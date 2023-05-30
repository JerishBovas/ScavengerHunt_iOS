//
//  TabBarView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-06.
//

import SwiftUI

struct TabBarView: View {
    @StateObject private var dashViewModel = DashViewModel()
    @StateObject private var gameViewModel = GameViewModel()
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            DashView(selection: $selection)
                .tabItem {
                    Label("Dashboard", systemImage: "doc.text.image.fill")
                }
                .tag(0)
            GamesView(selection: $selection)
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }
                .tag(1)
        }
        .environmentObject(dashViewModel)
        .environmentObject(gameViewModel)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
