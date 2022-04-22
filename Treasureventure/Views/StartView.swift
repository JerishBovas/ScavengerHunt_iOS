//
//  StartView.swift
//  Treasureventure
//
//  Created by Jerish Bovas on 2022-04-20.
//

import SwiftUI
import UIKit

struct StartView: View {
    let location: Location
    @State var image: Image? = nil
    @State var showCaptureImageView: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ZStack{
            VStack {
                if(image == nil){
                    LocationDetailView(location: location)
                    Text("Click \'view on map\' button and then go to that location. Once you found the object, click \'open camera\'button, take a picture and submit")
                    viewMapButton
                    openCameraButton
                }
            }
            VStack(alignment: .center, spacing: 40) {
                if(image != nil){
                    image?.resizable()
                      .frame(width: 250, height: 250)
                      .clipShape(Circle())
                      .overlay(Circle().stroke(Color.white, lineWidth: 4))
                      .shadow(radius: 10)
                    Text("Is this the correct item?")
                        .frame(alignment: .center)
                        .font(.headline)
                    confirmation
                }
            }
        }
        .sheet(isPresented: $showCaptureImageView) {
            CaptureImageView(isShown: $showCaptureImageView, image: $image)
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(location: LocationsDataService.locations.first!)
    }
}

extension StartView {
    private var viewMapButton : some View {
        Button {
            let url = URL(string: "maps://?saddr=&daddr=\(location.coordinates.latitude),\(location.coordinates.longitude)")
            if UIApplication.shared.canOpenURL(url!) {
                  UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
        }label: {
            Text("View on Map")
                .font(.headline)
                .frame(width: 125, height: 30)
        }
        .buttonStyle(.borderless)
    }
    
    private var openCameraButton: some View {
        Button(action: {
            self.showCaptureImageView.toggle()
        }) {
            Text("Open Camera")
                .font(.headline)
                .frame(width: 125, height: 30)
        }
        .buttonStyle(.borderedProminent)
        
    }
    private var confirmation: some View {
        
        HStack{
            Button {
                image = nil
            } label: {
                HStack{
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .frame(width: 135, height: 50)
                .background(.red)
            }
            .buttonStyle(.borderless)
            .cornerRadius(10)
            .padding(20)
            
            NavigationLink(destination: SuccessView(image: self.image!, location: location)) {
                HStack{
                    Image(systemName: "checkmark")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .frame(width: 135, height: 50)
                .background(.green)
            }
            .buttonStyle(.borderless)
            .cornerRadius(10)
            .padding(20)
//            Button {
//                image = nil
//            } label: {
//                HStack{
//                    Image(systemName: "checkmark")
//                        .font(.title)
//                        .foregroundColor(.white)
//                }
//                .frame(width: 135, height: 50)
//                .background(.green)
//            }
//            .buttonStyle(.borderless)
//            .cornerRadius(10)
//            .padding(20)
        }
    }
}
