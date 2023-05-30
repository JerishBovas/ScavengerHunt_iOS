//
//  GamesListView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-21.
//

import SwiftUI

struct GamesListView: View {
    @Binding var games: [Game]?
    @Binding var gameSource: Game?
    
    var body: some View {
        List {
            ForEach(games ?? [DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame(),DataService.getGame()]) { game in
                Button {
                    gameSource = game
                } label: {
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
                    .redacted(reason: games == nil ? .placeholder : [])
                }
            }
            .onDelete(perform: deleteItems)
            .onMove(perform: moveItems)
        }
        .listStyle(.plain)
    }
    private func moveItems(from source: IndexSet, to destination: Int) {
            games?.move(fromOffsets: source, toOffset: destination)
        }
    private func deleteItems(at offsets: IndexSet) {
        games?.remove(atOffsets: offsets)
    }
}

struct GamesListView_Previews: PreviewProvider {
    static var previews: some View {
        GamesListView(games: .constant(nil), gameSource: .constant(nil))
    }
}
