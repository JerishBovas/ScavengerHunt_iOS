//
//  GamesView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-03.
//

import SwiftUI

enum GameTabEnum: String, CaseIterable, Identifiable {
    case myGames = "My Games"
    case communityGames = "Community Games"
    
    var id: String { rawValue }
}

struct GamesView: View {
    @EnvironmentObject private var vm: GameViewModel
    @Binding var selection: Int
    @State private var tabSelection: GameTabEnum = .myGames
    @State private var searchString: String = ""
    @State private var showSheet = false
    @State private var gameUserSource: GameDetail?
    @State private var gameSource: GameDetail?
    var sortNames = ["Name", "Country", "Ratings", "Difficulty"]
    @State private var sortSelection: String = "Name"
    var perPage = ["10 Games", "20 Games", "30 Games", "40 Games"]
    @State private var pageSelection: String = "10 Games"
    
    var body: some View {
        NavigationStack{
            VStack{
                VStack(spacing: 8){
                    Picker("Games Tab", selection: $tabSelection) {
                        ForEach(GameTabEnum.allCases) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, 20)
                VStack{
                    if tabSelection == .myGames{
                        myGamesList
                            .tag(GameTabEnum.myGames)
                            .transition(.move(edge: .leading))
                    }
                    else{
                        communityGamesList
                            .tag(GameTabEnum.communityGames)
                            .transition(.move(edge: .trailing))
                    }
                }
                .animation(.spring(), value: tabSelection)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .navigationDestination(for: Game.self){ game in
                    GameDetailView(game: game)
                }
            }
            .toolbar{
                if tabSelection == .myGames{
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showSheet, content: {
                AddGameView(){ game, image in
                    try await vm.addGame(game: game, uiImage: image)
                }
            })
            .searchable(text: $searchString)
            .navigationTitle("Games")
            .navigationBarTitleDisplayMode(.inline)
            .alert(vm.appError?.title ?? "", isPresented: $vm.showAlert) {
                Text("OK")
            } message: {
                Text(vm.appError?.message ?? "")
            }
        }
        .environmentObject(vm)
    }
}

extension GamesView{
    private var myGamesList: some View{
        func deleteItems(at offsets: IndexSet) {
            vm.myGames?.remove(atOffsets: offsets)
        }
        return List {
            ForEach(vm.myGames ?? [DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame()]) { game in
                NavigationLink(value: game) {
                    HStack(spacing: 10){
                        ImageView(url: game.imageName)
                            .frame(width: 50, height: 50)
                            .cornerRadius(8, corners: .allCorners)
                        VStack(alignment: .leading, spacing: 3){
                            Text(game.name)
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            Text(game.address)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    .redacted(reason: vm.myGames == nil ? .placeholder : [])
                }
            }
            .onDelete(perform: deleteItems)
        }
        .task {
            if vm.myGames == nil{
                await vm.getMyGames()
            }
        }
        .refreshable {
            await vm.getMyGames()
        }
        .listStyle(.plain)
    }
    private var communityGamesList: some View{
        List {
            ForEach(vm.games ?? [DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame()]) { game in
                NavigationLink(value: game) {
                    HStack(spacing: 10){
                        ImageView(url: game.imageName)
                            .frame(width: 50, height: 50)
                            .cornerRadius(8, corners: .allCorners)
                        VStack(alignment: .leading, spacing: 3){
                            Text(game.name)
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            Text(game.address)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    .redacted(reason: vm.games == nil ? .placeholder : [])
                }
            }
        }
        .task {
            if vm.games == nil{
                await vm.getGames()
            }
        }
        .refreshable {
            await vm.getGames()
        }
        .listStyle(.plain)
    }
}

struct GamesView_Previews: PreviewProvider {
    static var previews: some View {
        GamesView(selection: .constant(0))
            .environmentObject(GameViewModel())
    }
}
