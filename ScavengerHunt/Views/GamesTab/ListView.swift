//
//  CardView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-20.
//

import SwiftUI
import UIKit

struct ListView: View {
    @State var game: Game
    
    var body: some View {
        NavigationLink(destination: GamesView()){
            HStack(alignment: .top, spacing: 15){
                AsyncImage(url: URL(string: game.imageName)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Color.random
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading){
                    Text(game.name)
                        .foregroundColor(.primary)
                        .font(.headline)
                    Text(game.address)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(game: GamesDataService.game)
    }
}
