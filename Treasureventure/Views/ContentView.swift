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
                    if(!filteredLocations.isEmpty){
                        ForEach(filteredLocations, id: \.self.id) { location in
                            CardView(location: location)
                        }
                        .listStyle(SidebarListStyle())
                    }
                    else{
                        Text("No Match")
                            .padding(20)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                        Text("Please refine your search")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
            }
            .navigationTitle("Treasureventure")
            .background(Color(UIColor.systemGray5))
        }
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
}
