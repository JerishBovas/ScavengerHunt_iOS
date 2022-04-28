//
//  MainView.swift
//  Treasureventure
//
//  Created by Jerish Bovas on 2022-04-26.
//

import SwiftUI

struct MainView: View {
    @AppStorage("firstTime") var isFirstTime: Bool = true
    
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("List", systemImage: "list.dash")
                }
            LocationsView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
        }
        .sheet(isPresented: $isFirstTime) {
            FirstBootView()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
