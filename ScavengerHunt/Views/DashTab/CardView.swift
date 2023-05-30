//
//  CardView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-03.
//

import SwiftUI

struct CardView: View {
    @State var game: Game
    @State var dimension: CGFloat
    
    var body: some View {
        ImageView(url: game.imageName)
            .frame(width: dimension, height: dimension)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay {
                VStack(alignment: .leading){
                    Spacer()
                    HStack{
                        VStack(alignment: .leading, spacing: 3){
                            Text(game.name)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text(game.address)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        NavigationLink("View", value: game)
                        .font(.headline)
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.borderedProminent)
                        .unredacted()
                        
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                }
            }
        
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(game: DataService.game, dimension: UIScreen.main.bounds.width - 60)
    }
}
