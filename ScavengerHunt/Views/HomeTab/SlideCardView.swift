//
//  CardView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-06-15.
//

import SwiftUI

struct SlideCardView: View {
    @State var game: Game
    
    var body: some View {
        VStack{
            AsyncImage(url: URL(string: game.imageName)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            VStack{
                Text(game.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text(game.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                Text(game.address)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(.bottom)
        }
        .frame(width: 340)
        .background(.ultraThickMaterial, in:
            Rectangle()
        )
        .cornerRadius(10)
    }
}

struct SlideCardView_Previews: PreviewProvider {
    static var previews: some View {
        SlideCardView(game: GamesDataService.game)
            .environmentObject(GameViewModel())
    }
}
