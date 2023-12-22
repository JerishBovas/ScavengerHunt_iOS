//
//  MapView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-08.
//

import SwiftUI
import MapKit

struct MapView: View{
    var newGame: NewGame
    @ObservedObject var completer: MapSearchCompleter
    @StateObject private var locationService = LocationService()
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAlert = false
    @State private var isSetting = false
    
    var body: some View{
        VStack {
            Map(bounds: .init(centerCoordinateBounds: completer.searchRegion), interactionModes: .all)
            .overlay(content: {
                MapIcon()
            })
            .edgesIgnoringSafeArea(.bottom)
        }
        .overlay(alignment: .topTrailing,content: {
            Button {
                switch locationService.authorizationStatus {
                case .authorizedWhenInUse:
                    if let location = locationService.currentLocation{
                        completer.searchRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), latitudinalMeters: 500, longitudinalMeters: 500)
                    }
                case .restricted, .denied:
                    showingAlert = true
                default:
                    return
                }
            } label: {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(Circle().fill(.primary).shadow(radius: 8))
                    
            }
            .padding()
        })
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Location Access Denied"),
                message: Text("Please grant location access in Settings"),
                primaryButton: .cancel(),
                secondaryButton: .default(Text("Settings")) {
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(settingsURL)
                }
            )
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task{
                        isSetting = true
                        await completer.reverseGeocode()
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    if isSetting{
                        ProgressView()
                    }else{
                        Text("Set")
                    }
                }
            }
        }
        .navigationTitle("Location")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $completer.searchQuery){
            ForEach(completer.searchResults, id: \.self) { result in
                SuggestionView(completer: completer, result: result)
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MapView(newGame: NewGame(), completer: MapSearchCompleter())
        }
    }
}

struct SuggestionView: View {
    @ObservedObject var completer: MapSearchCompleter
    var result: MKLocalSearchCompletion
    @Environment(\.dismissSearch) private var dismissSearch
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(result.title.isEmpty ? "N/A" : result.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text(result.subtitle.isEmpty ? "N/A" : result.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onTapGesture {
            completer.search(for: result)
            dismissSearch()
        }
    }
}

struct SuggestionView_Previews: PreviewProvider{
    static var previews: some View{
        SuggestionView(completer: MapSearchCompleter(), result: MKLocalSearchCompletion())
    }
}
