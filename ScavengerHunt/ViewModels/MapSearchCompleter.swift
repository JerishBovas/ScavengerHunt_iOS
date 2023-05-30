//
//  MapSearchCompleter.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2023-04-09.
//

import Foundation
import MapKit
import SwiftUI
import CoreLocation

class MapSearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    private let completer = MKLocalSearchCompleter()
    private var localSearch: MKLocalSearch?{
        willSet{
            localSearch?.cancel()
        }
    }
    
    @Published var place: CLPlacemark?
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var searchQuery: String = ""{
        didSet{
            search(query: searchQuery)
        }
    }
    @Published var searchRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 8.267222, longitude: 77.250518), latitudinalMeters: 500, longitudinalMeters: 500)

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results
    }

    func search(query: String) {
        completer.queryFragment = query
    }
    
    func search(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
    }
    
    func search(using searchRequest: MKLocalSearch.Request) {
        searchRequest.resultTypes = .address
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [unowned self] (response, error) in
            guard error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                if let updatedRegion = response?.boundingRegion {
                    withAnimation {
                        self.searchRegion = MKCoordinateRegion(center: updatedRegion.center, latitudinalMeters: 500, longitudinalMeters: 500)
                    }
                }
            }
        }
    }
    
    func reverseGeocode() async{
        let geocoder = CLGeocoder()
        let geoCode = try? await geocoder.reverseGeocodeLocation(CLLocation(latitude: searchRegion.center.latitude, longitude: searchRegion.center.longitude))
        guard let placemark = geoCode?.first else {
            return
        }
        DispatchQueue.main.async {
            self.place = placemark
        }
    }
}
