//
//  LocationDetailView.swift
//  MapApp
//
//  Created by Jerish Bovas on 2022-04-20.
//

import SwiftUI
import MapKit

struct LocationDetailView: View {
    
    @EnvironmentObject private var vm: LocationsViewModel
    
    let location: Location
    
    var body: some View {
        ScrollView {
            VStack{
                VStack( spacing: 16) {
                    titleSection
                    descriptionSection
                    Divider()
                    HStack{
                        VStack(alignment: .leading){
                            Image(location.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60, alignment: .leading)
                                .cornerRadius(10)
                            
                            Text(location.item)
                                .font(.title3)
                                .foregroundColor(.teal)
                                .frame(maxWidth: 120, alignment: .leading)
                        }
                        VStack(alignment: .trailing, spacing: 50){
                            RatingView(rating: .constant(location.ratings))
                            Text(location.difficulty.rawValue)
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                    Divider()
                    mapLayer
                    Divider()
                    backButton
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
        .background(.ultraThinMaterial)
    }
}

struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LocationDetailView(location:
                LocationsDataService.locations.first!)
        .environmentObject(LocationsViewModel())
    }
}

extension LocationDetailView {
    private var titleSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(location.name)
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text(location.address)
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(location.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var mapLayer: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(
            center: location.coordinates,
            span: vm.mapSpan)),
            annotationItems: [location]) { location in
            MapAnnotation(coordinate: location.coordinates) {
                LocationMapAnnotationView()
                    .shadow(radius: 10)
            }
        }
            .allowsHitTesting(false)
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(30)
    }
    
    private var backButton: some View {
        Button {
            vm.sheetLocation = nil
        }label: {
            HStack{
                Text("Okay")
                    .font(.headline)
                Image(systemName: "arrow.down")
                    .font(.headline)
            }
            .frame(width: 125, height: 30)
        }
        .buttonStyle(.borderedProminent)
        .padding(20)
    }
}
