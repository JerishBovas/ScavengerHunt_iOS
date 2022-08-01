//
//  StatSquareCard.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-06-28.
//

import SwiftUI

struct StatSquareCard: View {
    @Environment(\.colorScheme) var colorScheme
    @State var logo: String
    @State var logoColor: Color
    @State var value: Int
    @State var title: String
    
    var body: some View {
        ZStack {
            Color.clear
                .background(.regularMaterial, in:RoundedRectangle(cornerRadius: 14))
            VStack(spacing: 8){
                Label(title, systemImage: logo)
                    .font(.caption)
                    .foregroundColor(logoColor)
                Text(String(value))
                    .foregroundColor(.accentColor)
                    .font(.system(size: 35, weight: .semibold, design: .rounded))
            }
        }
        .frame(width: 100, height: 100)
    }
}

struct StatSquareCard_Previews: PreviewProvider {
    static var previews: some View {
        StatSquareCard(logo: "gamecontroller.fill", logoColor: .blue, value: 10, title: "Created")
    }
}
