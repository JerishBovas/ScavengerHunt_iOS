//
//  CardView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-06-15.
//

import SwiftUI

struct CardView: View {
    @EnvironmentObject private var vm: LocationsViewModel
    @State var location: Location
    
    var body: some View {
        VStack{
            Image(location.imageName)
            Text(location.name)
                .font(.title)
                .foregroundColor(.primary)
            Text(location.description)
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(location: LocationsDataService.location)
            .environmentObject(LocationsViewModel())
    }
}
