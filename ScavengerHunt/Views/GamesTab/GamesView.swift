//
//  ListGamesView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-19.
//

import SwiftUI

struct GamesView: View {
    
    @EnvironmentObject private var vm: GameViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var showingAbout = false
    @State private var searchText = ""
    @State private var selectedSort: Sort = .relevance
    @State private var isFetchingGames: Bool = false
    
    var body: some View {
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
                    if let temp = vm.temperature{
                        Text(String(temp))
                    }
                }
                .padding(.horizontal)
                Divider()
                VStack{
                    if(!isFetchingGames){
                        if(!filteredGames.isEmpty){
                            LazyVStack(alignment: .leading){
                                ForEach(filteredGames, id: \.self.id) { game in
                                    ListView(game: game)
                                        .padding(.leading)
                                        .animation(.spring(), value: filteredGames)
                                    Divider()
                                        .padding(.leading, 91)
                                }
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
                    isFetchingGames = true
                    Task{
                        if(authVM.user != nil && vm.games.isEmpty){
                            await vm.getGames()
                        }
                        isFetchingGames = false
                    }
                }
            }
            .alert(item: $vm.appError, content: { appError in
                Alert(title: Text(appError.title), message: Text(appError.message))
            })
            .navigationTitle("Games")
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

struct GamesView_Previews: PreviewProvider {
    static var previews: some View {
        GamesView()
            .environmentObject(GameViewModel())
            .environmentObject(AuthViewModel())
    }
}

extension GamesView {
    var filteredGames: [Game] {
        if searchText.isEmpty {
            return vm.games
        }
        else {
            return vm.games.filter {
              $0.name
                .localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
