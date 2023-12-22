//
//  CircleMap.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-05-31.
//

import SwiftUI
import MapKit

struct CircleMap: View {
    var userLocation: CLLocationCoordinate2D?
    var gameLocation: CLLocationCoordinate2D?
    
    var body: some View {
        Map(bounds: .init(minimumDistance: 1000)){
            UserAnnotation()
            if let coordinate = gameLocation{
                MapCircle(center: coordinate, radius: CLLocationDistance(10))
                    .foregroundStyle(.red)
                    .stroke(.white, lineWidth: 3)
            }
        }
        .aspectRatio(contentMode: .fit)
    }
}

struct CircleMap_Previews: PreviewProvider {
    static var previews: some View {
        CircleMap(userLocation: CLLocationCoordinate2D(latitude: 37.332331, longitude: -122.031219), gameLocation: CLLocationCoordinate2D(latitude: 37.332512, longitude: -122.030812))
    }
}

