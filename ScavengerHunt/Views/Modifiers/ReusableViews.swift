//
//  ReusableViews.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-05.
//

import SwiftUI

struct Wave: Shape {
    var offset: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        path.addCurve(to: CGPoint(x: width, y: midHeight),
                      control1: CGPoint(x: width * 0.25, y: midHeight - offset),
                      control2: CGPoint(x: width * 0.75, y: midHeight + offset))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}
