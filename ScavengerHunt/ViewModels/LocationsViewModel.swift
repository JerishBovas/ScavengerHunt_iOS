//
//  LocationsViewModel.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-20.
//

import Foundation
import MapKit
import SwiftUI

class LocationsViewModel: ObservableObject {
    
    @Published var locations = [Location]()
    @State var authVM = AuthViewModel()
    
    func getLocations() async{
        do{
            let defaults = UserDefaults.standard
            if(await !authVM.refreshToken()){
                return
            }
            
            guard let accessToken = defaults.string(forKey: "accessToken") else {
                return
            }
            
            let locs = try await ApiService().getLocations(accessToken: accessToken)
            print("Locations fetched")
            DispatchQueue.main.async {
                self.locations = locs
            }
        }
        catch{
            print("Request failed with error: \(error.localizedDescription)")
        }
    }
}
