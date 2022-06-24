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
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(1)
            LocationsView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Locations")
                }
                .tag(2)
            GroupsView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Groups")
                }
                .tag(3)
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
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
        .sheet(isPresented: $isFirstTime) {
            IntroSheetView()
        }
    }
}

struct NavBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavBarView()
    }
}
