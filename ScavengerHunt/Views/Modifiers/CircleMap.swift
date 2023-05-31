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
    
    private let mapRadius: CLLocationDistance = 200
    
    var body: some View {
        Map(coordinateRegion: .constant(region), showsUserLocation: true, annotationItems: annotations) { annotation in
            MapAnnotation(coordinate: annotation.coordinate) {
                ZStack{
                    Circle()
                        .fill(.red)
                        .frame(width: 18, height: 18)
                    Circle()
                        .stroke(.white, lineWidth: 3)
                        .frame(width: 18, height: 18)
                }
                .background{
                    ZStack{
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
                        Circle()
                            .stroke(Color.blue, lineWidth: 2)
                            .frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
                    }
                }
            }
        }
        .disabled(true)
        .aspectRatio(contentMode: .fit)
    }
    
    private var region: MKCoordinateRegion {
        if let gameLocation = gameLocation {
            return MKCoordinateRegion(center: gameLocation, latitudinalMeters: mapRadius * 2, longitudinalMeters: mapRadius * 2)
        } else {
            return MKCoordinateRegion()
        }
    }
    
    private var annotations: [CustomAnnotation] {
        var annotations: [CustomAnnotation] = []
        
        if let gameLocation = gameLocation {
            let gameAnnotation = CustomAnnotation(coordinate: gameLocation)
            annotations.append(gameAnnotation)
        }
        
        return annotations
    }
}

struct CustomAnnotation: Identifiable{
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct CircleMap_Previews: PreviewProvider {
    static var previews: some View {
        CircleMap(userLocation: CLLocationCoordinate2D(latitude: 37.332331, longitude: -122.031219), gameLocation: CLLocationCoordinate2D(latitude: 37.332512, longitude: -122.030812))
    }
}

