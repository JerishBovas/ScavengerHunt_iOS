//
//  ListLocationsView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-19.
//

import SwiftUI

struct LocationsView: View {
    
    @EnvironmentObject private var vm: LocationsViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var showingAbout = false
    @State private var searchText = ""
    @State private var selectedSort: Sort = .relevance
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true){
                VStack{
                    HStack{
                        Button {
                            
                        } label: {
                            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        }
                        Spacer()
                        HStack(spacing: 0){
                            Text("Sort By: ")
                            Picker("Sort", selection: $selectedSort) {
                                ForEach(Sort.allCases) { sort in
                                    Text(sort.rawValue.capitalized)
                                }
                            }
                        }
                    }
                    .padding(EdgeInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16)))
                    Divider()
                    VStack(alignment: .leading){
                        if(!filteredLocations.isEmpty){
                            ForEach(filteredLocations, id: \.self.id) { location in
                                ListView(location: location)
                                    .padding(.leading, 16)
                                    .animation(.default, value: filteredLocations)
                                Divider()
                                    .padding(.leading, 91)
                            }
                        }
                        else{
                            VStack{
                                Text("No Match")
                                    .padding(20)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                Text("Please refine your search")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .onAppear{
                        Task{
                            if(authVM.user != nil && vm.locations.isEmpty){
                                await vm.getLocations()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Locations")
            .searchable(text: $searchText, prompt: "Search")
            .toolbar(content: {
                ToolbarItem (placement: .navigation)  {
                    EditButton()
                }
                 ToolbarItem (placement: .automatic)  {
                     Button(action: {
                         
                     }, label: {
                         Image(systemName: "plus")
                     })
                 }
             })
        }
    }
}

struct LocationsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsView()
            .environmentObject(LocationsViewModel())
            .environmentObject(AuthViewModel())
    }
}

extension LocationsView {
    var filteredLocations: [Location] {
        if searchText.isEmpty {
            return vm.locations
        }
        else {
            return vm.locations.filter {
              $0.name
                .localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
