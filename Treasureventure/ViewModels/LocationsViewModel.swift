//
//  LocationsViewModel.swift
//  Treasureventure
//
//  Created by Jerish Bovas on 2022-04-20.
//

import Foundation
import MapKit
import SwiftUI

class LocationsViewModel: ObservableObject {
    
    @Published var locations: [Location]
    
    @Published var mapLocation: Location {
        didSet {
            updateMapRegion(location: mapLocation)
        }
    }
    
    //Current region on map
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    let mapSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    //Show list of location
    @Published var showLocationsList: Bool = false;
    
    //Show location details via sheet
    @Published var sheetLocation: Location? = nil
    
    init(){
        let locations = LocationsDataService.locations
        self.locations = locations
        self.mapLocation = locations.first!
        self.updateMapRegion(location: locations.first!)
    }
    public func updateMapLocation(thisLocation: Location){
        withAnimation(.easeOut){
            mapLocation = thisLocation
        }
    }
    private func updateMapRegion(location: Location){
        withAnimation(.easeOut){
            mapRegion = MKCoordinateRegion(center: location.coordinates, span: mapSpan)
        }
    }
    
    public func toggleLocationsList(){
        withAnimation(.easeOut){
            showLocationsList = !showLocationsList
        }
    }
    
    func showNextLocation(location: Location){
        withAnimation(.easeOut){
            mapLocation = location
            showLocationsList = false
        }
    }
    
    func nextButtonPressed(){
        
        //Get Current index
        guard let currentIndex = locations.firstIndex(where: {$0 == mapLocation}) else {
            print("Could not find index")
            return
        }
        
        //Check if the currentIndex is valid
        let nextIndex = currentIndex + 1
        guard locations.indices.contains(nextIndex) else {
            //Next index is NOT valid
            //Restart from 0
            guard let firstLocation = locations.first else { return}
            showNextLocation(location: firstLocation)
            return
        }
        
        let nextLocation = locations[nextIndex]
        showNextLocation(location: nextLocation)
    }
}
