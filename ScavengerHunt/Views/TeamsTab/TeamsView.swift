//
//  ListGamesView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-19.
//

import SwiftUI

struct TeamsView: View {
    
    @EnvironmentObject private var vm: TeamViewModel
    @State private var showingAbout = false
    @State private var searchText = ""
    @State private var selectedSort: Sort = .relevance
    @State private var isFetchingTeams: Bool = false
    
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
                    .padding(.horizontal)
                    Divider()
                    VStack(alignment: .leading){
                        if(!isFetchingTeams){
                            if(!filteredTeams.isEmpty){
                                ForEach(filteredTeams, id: \.self.id) { team in
                                    TeamListView(team: team)
                                        .padding(.leading)
                                        .animation(.spring(), value: filteredTeams)
                                    Divider()
                                        .padding(.leading, 91)
                                }
                            }
                            else{
                                VStack{
                                    Text("No Match")
                                        .padding()
                                        .font(.headline)
                                    Text("Please refine your search")
                                        .font(.subheadline)
                                }
                            }
                        }else{
                            HStack(alignment: .center){
                                ProgressView()
                            }
                        }
                    }
                    .onAppear{
                        isFetchingTeams = true
                        Task{
                            if(vm.teams.isEmpty){
                                await vm.getTeams()
                            }
                            isFetchingTeams = false
                        }
                    }
                }
            }
            .alert(item: $vm.appError, content: { appError in
                Alert(title: Text(appError.title), message: Text(appError.message))
            })
            .navigationTitle("Teams")
            .searchable(text: $searchText, prompt: "Search")
            .toolbar(content: {
                ToolbarItem (placement: .navigationBarLeading)  {
                    EditButton()
                }
                ToolbarItem (placement: .navigationBarTrailing)  {
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            })
        }
    }
}

struct TeamsView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsView()
            .environmentObject(TeamViewModel())
            .environmentObject(HomeViewModel())
    }
}

extension TeamsView {
    var filteredTeams: [Team] {
        if searchText.isEmpty {
            return vm.teams
        }
        else {
            return vm.teams.filter {
                $0.title
                    .localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
