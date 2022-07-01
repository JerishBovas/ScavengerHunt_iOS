//
//  StatSquareCard.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-06-28.
//

import SwiftUI

struct StatSquareCard: View {
    @State var logo: String
    @State var logoColor: Color
    @State var value: Int
    @State var title: String
    
    var body: some View {
        VStack{
            Image(systemName: logo)
                .foregroundColor(logoColor)
                .frame(maxWidth: .infinity,alignment: .leading)
            Text(String(value))
                .foregroundColor(.accentColor)
                .font(.system(size: 35, weight: .semibold, design: .rounded))
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThickMaterial, in:
                        RoundedRectangle(cornerRadius: 10)
        )
    }
}

struct StatSquareCard_Previews: PreviewProvider {
    static var previews: some View {
        StatSquareCard(logo: "gamecontroller.fill", logoColor: .blue, value: 10, title: "Created")
    }
}
