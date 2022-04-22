//
//  LocationsView.swift
//  Treasureventure
//
//  Created by Jerish Bovas on 2022-04-20.
//

import SwiftUI
import MapKit

struct LocationsView: View {
    
    @EnvironmentObject private var vm: LocationsViewModel
    @Environment(\.presentationMode) var presentation
    let maxWidthForIpad: CGFloat = 700
    
    var body: some View {
        ZStack {
            mapLayer
                .ignoresSafeArea()
            VStack(spacing: 0){
                header
                    .padding()
                    .frame(maxWidth: maxWidthForIpad)
                Spacer()
                
                locationsPreviewStack
            }
        }
        .sheet(item: $vm.sheetLocation, onDismiss: nil) { location in
            LocationDetailView(location: location)
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
           .toolbar(content: {
              ToolbarItem (placement: .navigation)  {
                  Button(action: {
                      self.presentation.wrappedValue.dismiss()
                  }, label: {
                      Image(systemName: "chevron.left")
                      Text("Back")
                  })
                  .buttonStyle(.bordered)
              }
               ToolbarItem (placement: .automatic)  {
                   Menu{
                       Button {
                           actionSheet()
                       } label: {
                           Label("Share Location", systemImage: "square.and.arrow.up")
                       }
                       .background(.white)

                       Button {
                           print("Enable geolocation")
                       } label: {
                           Label("About App", systemImage: "info.circle")
                       }
                   }label: {
                       Image(systemName: "ellipsis.circle")
                           .foregroundColor(.accentColor)
                   }
               }
           })
    }
}

struct LocationsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsView()
            .environmentObject(LocationsViewModel())
    }
}

extension LocationsView {
    private var header: some View {
        VStack {
            Button(action: vm.toggleLocationsList) {
                Text(vm.mapLocation.name)
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .animation(.none, value: vm.mapLocation)
                    .overlay(alignment: .leading) {
                        Image(systemName: "arrow.down")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding()
                            .rotationEffect(Angle(degrees: vm.showLocationsList ? 180 : 0))
                    }
            }
            
            if(vm.showLocationsList){
                LocationsListView()
            }
        }
        .background(.thickMaterial)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 15)
    }
    
    private var mapLayer: some View {
        Map(coordinateRegion: $vm.mapRegion,
            annotationItems: vm.locations,
            annotationContent: { location in
            MapAnnotation(coordinate: location.coordinates) {
                LocationMapAnnotationView()
                    .scaleEffect(vm.mapLocation == location ? 1 : 0.7)
                    .shadow(radius: 10)
                    .onTapGesture {
                        vm.showNextLocation(location: location)
                    }
            }
        })
    }
    
    private var locationsPreviewStack: some View {
        ZStack {
            ForEach(vm.locations) { location in
                if vm.mapLocation == location {
                    LocationPreviewView(location: location)
                        .shadow(color: .black.opacity(0.3), radius: 20)
                        .padding()
                        .frame(maxWidth: maxWidthForIpad)
                        .frame(maxWidth: .infinity)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)))
                }
            }
        }
    }
    private func actionSheet() {
        let loc = vm.mapLocation
        guard let urlApple = URL(string: "http://maps.apple.com/?ll=\(loc.coordinates.latitude),\(loc.coordinates.longitude)") else {return}
        let task = "Place name: \(loc.name)\nItem to find: \(loc.item)\nDifficulty: \(loc.difficulty.rawValue)"
        let activityVC = UIActivityViewController(activityItems: [task,urlApple], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}
