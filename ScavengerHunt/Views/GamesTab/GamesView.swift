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
                        if(!filteredGames.isEmpty){
                            ForEach(filteredGames, id: \.self.id) { game in
                                ListView(game: game)
                                    .padding(.leading, 16)
                                    .animation(.default, value: filteredGames)
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
                            if(authVM.user != nil && vm.games.isEmpty){
                                await vm.getGames()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Games")
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
