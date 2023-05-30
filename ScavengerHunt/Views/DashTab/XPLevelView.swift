//
//  XPLevelView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-22.
//

import SwiftUI

struct XPLevelView: View {
    @State private var xp: Int = 800
    @State private var currentXP: Int = 450
    @State private var level: Int = 4

    private var progress: CGFloat {
        CGFloat(currentXP) / CGFloat(xp)
    }

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(.white.opacity(0.3))
                .frame(height: 5)
                .overlay(
                    GeometryReader(content: { geo in
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(.white)
                            .frame(width: geo.size.width * progress, height: 5, alignment: .leading)
                            .animation(.linear(duration: 0.5), value: progress)
                    })
                )
            HStack {
                Text("Level \(level)")
                    .font(.body)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                Spacer()
                Text("\(currentXP)/\(xp)")
                    .font(.footnote)
                    .foregroundColor(.white)
                Text("XP")
                    .font(.footnote)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
        }
    }
}

struct XPLevelView_Previews: PreviewProvider {
    static var previews: some View {
        XPLevelView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
