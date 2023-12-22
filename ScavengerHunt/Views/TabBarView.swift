//
//  TabBarView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 8/19/23.
//

import SwiftUI

enum Tab{
    case home
    case games
    case teams
    case account
}

struct TabBarView: View {
    @State private var selectedTab: Tab = .home
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var gameViewModel = GameViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab,
                content:  {
            HomeView().tabItem { Label("Home", systemImage: "house.fill") }.tag(Tab.home)
            GamesView().tabItem { Label("Games", systemImage: "gamecontroller.fill") }.tag(Tab.games)
            HomeView().tabItem { Label("Teams", systemImage: "person.3.fill") }.tag(Tab.teams)
            HomeView().tabItem { Label("Settings", systemImage: "gear") }.tag(Tab.account)
        })
        .environmentObject(homeViewModel)
        .environmentObject(profileViewModel)
        .environmentObject(gameViewModel)
    }
}

#Preview {
    TabBarView()
}
