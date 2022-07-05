//
//  ListGamesView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-19.
//

import SwiftUI

struct TeamsView: View {
    
    @EnvironmentObject private var vm: TeamViewModel
    @EnvironmentObject private var authVM: AuthViewModel
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
                    .padding(EdgeInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16)))
                    Divider()
                    VStack(alignment: .leading){
                        if(!isFetchingTeams){
                            if(!filteredTeams.isEmpty){
                                ForEach(filteredTeams, id: \.self.id) { team in
                                    TeamListView(team: team)
                                        .padding(.leading, 16)
                                        .animation(.spring(), value: filteredTeams)
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
                        }else{
                            HStack(alignment: .center){
                                ProgressView()
                            }
                        }
                    }
                    .onAppear{
                        isFetchingTeams = true
                        Task{
                            if(authVM.user != nil && vm.teams.isEmpty){
                                await vm.getTeams()
                            }
                            isFetchingTeams = false
                        }
                    }
                }
            }
            .navigationTitle("Teams")
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

struct TeamsView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsView()
            .environmentObject(TeamViewModel())
            .environmentObject(AuthViewModel())
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
