//
//  BadgeBackground.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-08-17.
//

import SwiftUI

struct BadgeBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                
                path.move(to: CGPoint(x: 20, y: 0))
                path.addLine(to: CGPoint(x: 20, y: 20))
                path.addLine(to: CGPoint(x: 40, y: 20))
                path.addLine(to: CGPoint(x: 40, y: 0))
                
//                var width: CGFloat = min(geometry.size.width, geometry.size.height)
//                let height = width
//                path.move(
//                    to: CGPoint(
//                        x: width * 0.95,
//                        y: height * (0.20 + HexagonParameters.adjustment)
//                    )
//                )
//                
//                
//                HexagonParameters.segments.forEach { segment in
//                    path.addLine(
//                        to: CGPoint(
//                            x: width * segment.line.x,
//                            y: height * segment.line.y
//                        )
//                    )
//                    
//                    
//                    path.addQuadCurve(
//                        to: CGPoint(
//                            x: width * segment.curve.x,
//                            y: height * segment.curve.y
//                        ),
//                        control: CGPoint(
//                            x: width * segment.control.x,
//                            y: height * segment.control.y
//                        )
//                    )
//                }
            }
            .fill(.primary)
        }
    }
}

#Preview {
    BadgeBackground()
}
