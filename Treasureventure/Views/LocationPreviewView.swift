//
//  LocationPreviewView.swift
//  MapApp
//
//  Created by Jerish Bovas on 2022-04-20.
//

import SwiftUI

struct LocationPreviewView: View {
    
    @EnvironmentObject private var vm: LocationsViewModel
    let location: Location
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 16.0) {
                
                imageSection
                
                VStack(alignment: .leading, spacing: 4.0) {
                    Text(location.address)
                        .font(.subheadline)
                    Button("View on Map"){
                        let url = URL(string: "maps://?saddr=&daddr=\(location.coordinates.latitude),\(location.coordinates.longitude)")
                        if UIApplication.shared.canOpenURL(url!) {
                              UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                        }
                    }
                    .buttonStyle(.borderless)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack(spacing: 15) {
                titleSection
                startButton
                learnMoreButton
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .offset(y: 65)
        )
        .cornerRadius(10)
    }
}

struct LocationPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.green.ignoresSafeArea()
            
            LocationPreviewView(location: LocationsDataService.locations.first!)
                .padding()
        }
        .environmentObject(LocationsViewModel())
    }
}

extension LocationPreviewView {
    
    private var imageSection: some View {
        ZStack {
            if let imageName = location.image {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
            }
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private var titleSection: some View {
        VStack(alignment: .center, spacing: 4.0) {
            Text(location.name)
                .font(.title2)
        }
        .frame(width: 180)
    }
    
    private var startButton : some View {
        NavigationLink(destination: StartView(location: location)){
            Text("Start")
                .font(.headline)
                .frame(width: 125, height: 30)
        }
        .buttonStyle(.borderedProminent)
    }
    
    private var learnMoreButton : some View {
        Button {
            vm.sheetLocation = location
        }label: {
            Text("Learn more")
                .font(.headline)
                .frame(width: 125, height: 30)
        }
        .buttonStyle(.borderless)
    }
}
