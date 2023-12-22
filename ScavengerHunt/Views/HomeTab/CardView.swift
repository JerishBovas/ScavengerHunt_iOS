//
//  CardView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-03.
//

import SwiftUI

struct CardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State var game: Game
    
    var body: some View {
        NavigationLink(value: game) {
            VStack(alignment: .leading){
                ImageView(url: game.imageName)
                    .frame(width: 250, height: 160)
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.gray.opacity(0.4).shadow(.inner(radius: 1)),lineWidth: 1.0))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .blendMode(colorScheme == .dark ? .lighten : .darken)
                VStack(alignment: .leading){
                    Text(game.name)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(Color.primary)
                        .lineLimit(1)
                    Text(game.address)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(game: DataService.game)
    }
}
