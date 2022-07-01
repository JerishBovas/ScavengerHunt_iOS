//
//  MainView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-26.
//

import SwiftUI

struct NavBarView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @AppStorage("firstTime") var isFirstTime: Bool = true
    @State private var tabSelection = 1
    
    var body: some View {
        TabView(selection: $tabSelection) {
            HomeView(tabSelection: $tabSelection)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .sheet(isPresented: $isFirstTime) {
                    IntroSheetView()
                }
                .tag(1)
            GamesView()
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }
                .tag(2)
            GroupsView()
                .tabItem {
                    Label("Teams", systemImage: "person.2")
                }
                .tag(3)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .onAppear{
            Task{
                if(await authVM.refreshToken()){
                    authVM.isAuthenticated = true
                }
            }
        }
        .sheet(isPresented: $authVM.showLogin) {
            LoginSheetView()
        }
    }
}

struct NavBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavBarView()
    }
}
