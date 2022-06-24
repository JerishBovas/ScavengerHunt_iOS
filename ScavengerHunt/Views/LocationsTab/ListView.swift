//
//  CardView.swift
//  ScavengerHunt
//
//  Created by Jerish Bovas on 2022-04-20.
//

import SwiftUI

struct ListView: View {
    @State var location: Location
    
    var body: some View {
        NavigationLink(destination: LocationsView()){
            HStack(alignment: .top, spacing: 15){
                Image(location.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                VStack(alignment: .leading){
                    Text(location.name)
                        .foregroundColor(.primary)
                        .font(.headline)
                    Text(location.address)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(location: LocationsDataService.location)
    }
}
