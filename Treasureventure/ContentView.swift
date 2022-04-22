//
//  ContentView.swift
//  Treasureventure
//
//  Created by Jerish Bovas on 2022-04-19.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var vm: LocationsViewModel
    @State private var showingAbout = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            
            ScrollView{
                VStack{
                    ForEach(filteredLocations, id: \.self.id) { location in
                        CardView(location: location)
                    }
                    .listStyle(SidebarListStyle())
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
            }
            .navigationTitle("Treasureventure")
            .toolbar {
                Button {
                    showingAbout.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
                .sheet(isPresented: $showingAbout) {
                    AboutView
                }

            }
            .background(Color(UIColor.systemGray5))
        }
        .navigationBarBackButtonHidden(true)
        .searchable(text: $searchText, prompt: "Search")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LocationsViewModel())
    }
}

extension ContentView {
    var filteredLocations: [Location] {
      if searchText.isEmpty {
        // 1
          return vm.locations
      } else {
        // 2
          return vm.locations.filter {
              $0.name
                .localizedCaseInsensitiveContains(searchText)
            }
      }
    }
    
    private var AboutView: some View {
        ZStack {
            Image("Pooja")
                .resizable()
                .scaledToFill()
                .opacity(0.5)
            VStack{
                Spacer()
                Text("101239138   Jerish Bovas")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("101244671   Jesse Hughes")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("101232944   Sanjay Kannan")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("101195416   Arun Sunny")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .foregroundColor(.primary)
        }
        .ignoresSafeArea()
    }
}
