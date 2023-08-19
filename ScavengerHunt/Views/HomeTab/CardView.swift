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
                    NavigationLink(value: game, label: {
                        HStack{
                            ImageView(url: game.imageName)
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
                            VStack(alignment: .leading, spacing: 5){
                                Text(game.name)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Text(game.address)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    })
                    .padding()
                    .background(.regularMaterial)
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
