//
//  MapIcon.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-11.
//

import SwiftUI

struct MapIcon: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            Triangle()
                .fill(colorScheme == .dark ? Color(hex: "dcddde") : Color(hex: "ffffff"))
                .frame(width: 27, height: 17)
                .rotationEffect(.degrees(180))
                .offset(.init(width: 0, height: 16))
            Circle()
                .fill(Color.accentColor)
                .frame(width: 25, height: 25)
            Circle()
                .stroke(lineWidth: 5)
                .fill(colorScheme == .dark ? Color(hex: "dcddde") : Color(hex: "ffffff"))
                .frame(width: 30, height: 30)
        }
        .background(Circle().fill().shadow(color: Color.gray.opacity(0.7),
                                    radius: 8,
                                    x: 0,
                                    y: 0))
        .offset(.init(width: 0, height: -40 ))
    }
}

struct MapIcon_Previews: PreviewProvider {
    static var previews: some View {
        MapIcon()
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}
