//
//  CardView.swift
//  Treasureventure
//
//  Created by Jerish Bovas on 2022-04-20.
//

import SwiftUI

struct CardView: View {
    
    @EnvironmentObject private var vm: LocationsViewModel
    @State var location: Location
    let totalStars: Int = 5
    
    var body: some View {
        VStack {
            HStack {
                
                VStack(alignment: .leading){
                    Image(location.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(10)
                    
                    Text(location.item)
                        .font(.title3)
                        .foregroundColor(.teal)
                        .frame(maxWidth: 120, alignment: .leading)
                }
                Spacer()
                VStack(alignment: .center, spacing: 10){
                    Text(location.name)
                        .font(.title2)
                    Text(location.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            HStack{
                RatingView(rating: .constant(location.ratings))
                Spacer()
                Text(location.difficulty.rawValue)
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
                NavigationLink(destination: LocationsView()) {
                    Text("View")
                        .font(.headline)
                    Image(systemName: "chevron.right")
                    }.simultaneousGesture(TapGesture().onEnded{
                        withAnimation(.easeOut){
                            vm.mapLocation = location
                        }
                })
                .buttonStyle(.borderless)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.linearGradient(colors: [Color(UIColor.systemBackground),Color(UIColor.systemGray5)], startPoint: .leading, endPoint: .trailing))
                .frame(maxWidth: .infinity)
        )
        .cornerRadius(10)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(location: LocationsDataService.locations.first!)
            .environmentObject(LocationsViewModel())
    }
}
